--** @h:\dman\dbman\problems\fixes\sap\dbtune5.sql DV3x

--** Version 9i Report

spool /epoq1/oracle/local/reports/dbhealth.lst 


REM =======================================================================
REM Database Health Check Script
REM =======================================================================
REM Author : D.Preston 08/08/2003
REM Reason : This script generates a health check report for Oracle 9i databases
REM =======================================================================

set feedback off
set verify off
set pagesize 10000
set linesize 179
set termout off
set heading off

prompt
prompt
prompt ********************************************************************
prompt Database Health Check Report
prompt ********************************************************************
prompt

-- setup date filename

col xdate noprint new_value thisdate
col ydate noprint new_value todaysdate
col dbnme noprint new_value dbreport


select to_char(sysdate,'YYYYMMDD') xdate
      ,to_char(sysdate,'DD-MON-YYYY') ydate
from dual
/

select name dbnme from v$database
/

prompt
prompt ====================================================================
prompt Date 		: &&todaysdate
prompt Database 	: &&dbreport
prompt ====================================================================

prompt
prompt ********************************************************************
prompt                             Profile
prompt ********************************************************************
prompt

Select * from v$version
/ 

col value format a20
col parameter format a40

Select * from v$option
/

Select comp_name, version, status from dba_registry
/ 

select * from nls_database_parameters where parameter  
='NLS_NCHAR_CHARACTERSET'
/ 

select OWNER, TABLE_NAME , count(*) no_nchar
from DBA_TAB_COLUMNS 
where DATA_TYPE in ('NCHAR','NVARCHAR2', 'NCLOB')
group by OWNER, TABLE_NAME 
order by OWNER, TABLE_NAME
/

prompt As of Oracle 9i the sql NCHAR datatypes will be limited to the Unicode  
prompt characterset encoding only (UTF8 and AL16UTF16). Any other NCHAR datatype  
prompt will no longer be supported. 


prompt  
prompt------------------------------------------------------------------------
prompt 


prompt
prompt ********************************************************************
prompt                             Storage
prompt ********************************************************************
prompt


col name format a15  
col target format a15
col actual format 9999999  
col pct_used format 9999999

prompt ====================================================================
prompt Datafile Usage
prompt ====================================================================

set heading on

prompt Profile of Datafile usage

select p.name,max(p.value) target,count(*) actual,
round(((count(*)/max(p.value))*100),0) pct_used
from dba_data_files d,V$parameter p
where p.name = 'db_files'
group by p.name
/

prompt Files needing recovery

Select * from v$recover_file
/

prompt Files in backup mode

Select * from v$backup where status!='NOT ACTIVE'
/

set heading off


prompt  
prompt------------------------------------------------------------------------

prompt ====================================================================
prompt Tablespace Fragmentation
prompt ====================================================================
prompt 
 
set heading on

select b.tablespace_name,       
       round(sum(b.bytes)/(1024*1024),0) fbytes,
       round(max(b.bytes)/(1024*1024),0) mbytes,
       round((max(b.bytes)/sum(b.bytes))*100,0) FSFI,
       count(*) kount  
from   dba_free_space b 
having round((max(b.bytes)/sum(b.bytes))*100,0) < 30
group  by b.tablespace_name  
order  by b.tablespace_name  
/  
 

set heading off

prompt  
prompt A large number of Free Chunks indicates that the tablespace may need  
prompt to be defragmented and compressed.  
prompt  
prompt -----------------------------------------------------------------  
  
prompt
prompt ====================================================================
prompt Display all Tablespaces > 80% Full
prompt ====================================================================

set heading on

select d.tablespace_name "name",
       d.status "status",
       to_char((a.bytes/1024 / 1024),'99,999,990.900') "Size Mb",
       to_char(((a.bytes-decode(f.bytes,'',0,f.bytes))/1024/1024),'99,999,990.900') "Used Mb",
       round(((a.bytes-decode(f.bytes,'',0,f.bytes))/1024/1024)
             / (a.bytes/1024/1024)*100,2) "%Used"
from sys.dba_tablespaces d, sys.sm$ts_avail a, sys.sm$ts_free f
where d.tablespace_name = a.tablespace_name
and f.tablespace_name (+) = d.tablespace_name
and (d.status != 'ONLINE'
     or
     round(((a.bytes-decode(f.bytes,'',0,f.bytes))/1024/1024)
             / (a.bytes/1024/1024)*100,2) > 80
     )
order by 1
/

set heading off


prompt  
prompt -----------------------------------------------------------------  

prompt
prompt
prompt
prompt ====================================================================
prompt Summary of all objects EXCEEDING 150 extent threshold
prompt ====================================================================

set heading on


 
select t.extent_management,s.segment_type,count(*)
from dba_segments s, dba_tablespaces t
where s.extents >= 150
and   s.tablespace_name = t.tablespace_name
group by t.extent_management,s.segment_type
order by t.extent_management,s.segment_type
/


set heading off


prompt  
prompt -----------------------------------------------------------------  
  


col owner           format a10
col segment_name    format a25
col tablespace_name format a15

prompt
prompt
prompt
prompt ====================================================================
prompt Show all non-locally managed objects EXCEEDING 150 extent threshold
prompt ====================================================================

set heading on

select s.segment_name,
       s.segment_type,
       s.tablespace_name,
       s.extents Txtnts,
       round(s.initial_extent/(1024*1024),0) init_mb,
       round(s.next_extent/(1024*1024),0) next_mb
from dba_segments s
where s.extents >= 150
and   s.tablespace_name in (select tablespace_name
                            from dba_tablespaces
                            where extent_management = 'DICTIONARY')
/

set heading off

prompt  
prompt -----------------------------------------------------------------  
  

col table_name    format a25
col partition_name format a15

prompt
prompt
prompt
prompt ====================================================================
prompt Tables most likely to benefit from a reorg
prompt ====================================================================

set heading on



select p.table_name,p.partition_name
,round((p.chain_cnt*100)/p.num_rows,0) "pct_chn"
,round((((p.blocks - ((p.AVG_ROW_LEN*p.num_rows)/(8*1024)))*100)/p.blocks) - (p.pct_free),0) "pct_wst_spc"
from dba_tab_partitions p
where p.blocks > 0
and p.num_rows > 0
and p.AVG_ROW_LEN > 0
and p.blocks * 8 > (1024*1024)
and (
(p.blocks - ((p.AVG_ROW_LEN*p.num_rows)/(8*1024))) > (0.5 * p.blocks)
or p.chain_cnt > 0.2 * p.num_rows)
and not exists
(select 'x'
 from dba_tab_columns c
  where c.owner = p.table_owner
   and c.table_name = p.table_name
   and c.data_type like '%LONG%RAW%')
union all
select t.table_name,' '
,round((t.chain_cnt*100)/t.num_rows,0) "pct_chn"
,round((((t.blocks - ((t.AVG_ROW_LEN*t.num_rows)/(8*1024)))*100)/t.blocks) - (t.pct_free),0) "pct_wst_spc"
from dba_tables t
where t.blocks > 0
and t.num_rows > 0
and t.AVG_ROW_LEN > 0
and t.blocks * 8 > (1024*1024)
and t.pct_free > 0
and (
(t.blocks - ((t.AVG_ROW_LEN*t.num_rows)/(8*1024))) > (0.5 * t.blocks)
or t.chain_cnt > 0.2 * t.num_rows)
and not exists
(select 'x'
 from dba_tab_columns c
  where c.owner = t.owner
   and c.table_name = t.table_name
   and c.data_type like '%LONG%RAW%')
;



set heading off

prompt  
prompt -----------------------------------------------------------------  
prompt




prompt
prompt
prompt
prompt ====================================================================
prompt Show all non-locally managed objects > than 80% of MAXEXTENTS
prompt ====================================================================

set heading on

select s.segment_name,
       s.segment_type,
       s.tablespace_name,
       s.extents Txtnts,
       s.max_extents Mxtnts,
       round(s.initial_extent/(1024*1024),0) init_mb,
       round(s.next_extent/(1024*1024),0) next_mb
from dba_segments s
where s.extents > 0.8 * s.max_extents
and   s.tablespace_name in (select tablespace_name
                            from dba_tablespaces
                            where extent_management = 'DICTIONARY')
/

set heading off

prompt  
prompt -----------------------------------------------------------------  
  

prompt
prompt ====================================================================
prompt Show objects that only have 2 extents growth 'in hand'
prompt ====================================================================


set heading on

select s.owner
      ,s.segment_name
      ,s.tablespace_name
      ,round(s.bytes/(1024*1024),0) "Size Mb"
      ,round(s.next_extent/(1024*1024),0) "Next Ext Mb"
      ,round(f.avg_free_bytes/(1024*1024),0) "Avg Free Mb"
      ,round(f.max_free_bytes/(1024*1024),0) "Max Free Mb"
      ,round(f.sum_free_bytes/(1024*1024),0) "Tot Free Mb"
      ,s.extents "Xnts"
      ,s.max_extents "Max Xnts"
from sys.dba_segments s,
       (select t.tablespace_name
        ,avg(nvl(b.bytes,0)) avg_free_bytes
        ,max(nvl(b.bytes,0)) max_free_bytes
        ,sum(nvl(b.bytes,0)) sum_free_bytes
        from sys.dba_free_space b,sys.dba_tablespaces t
        where t.tablespace_name = b.tablespace_name (+)
        group by t.tablespace_name) f
where s.tablespace_name=f.tablespace_name
and  (((1+(6*(PCT_INCREASE/100)))* s.next_extent) > f.max_free_bytes
      or    
      s.extents = (s.max_extents * 0.8))
/

set heading off

prompt  
prompt -----------------------------------------------------------------  

prompt ********************************************************************
prompt                             Memory
prompt ********************************************************************
prompt

col name format a40  
col component format a40 

prompt ====================================================================
prompt SGA
prompt ====================================================================
prompt 

prompt  
prompt This shows the allocation of SGA storage.  Examine this before and  
prompt after making changes in the INIT.ORA file which will impact the SGA.  
prompt  

select name,round(value/(1024*1024),0) Size_mb 
from v$parameter where name like 'sga%'
/

select pool,round(sum(bytes)/(1024*1024),0) SIZE_MB 
from v$sgastat
group by pool
order by pool
/

select name,round(value/(1024*1024),0) Size_mb 
from v$parameter where name in 
('shared_pool_size',
'shared_pool_reserved_size',
'large_pool_size')
/

prompt The default value for SHARED_POOL_RESERVED_SIZE is 5% of the SHARED_POOL_SIZE. 
prompt In general, set SHARED_POOL_RESERVED_SIZE to 10% of SHARED_POOL_SIZE. 
 

set heading on

prompt
prompt Dynamic SGA
prompt


select component
,current_size/(1024*1024) current_mb
,granule_size/(1024*1024) granule_mb
from v$sga_dynamic_components
/

prompt
prompt Dynamic SGA Free Space
prompt


select current_size/(1024*1024) free_mb
from v$sga_dynamic_free_memory
/

prompt
prompt Buffer Pool 
prompt

select name,block_size blk_bytes,current_size current_mb
from v$buffer_pool
/

prompt
prompt Re-size Operations on the SGA
prompt

select component,oper_type,count(*)
from v$sga_resize_ops
group by component,oper_type
order by component,oper_type
/


set heading off

prompt  
prompt------------------------------------------------------------------------  



prompt ====================================================================
prompt Library Cache Statistics
prompt ====================================================================

select 'PINS    - # of times an item in the library cache was executed - '||  
        sum(pins),  
       'RELOADS - # of library cache misses on execution steps         - '|| 
        sum (reloads),  
       'RELOADS / PINS * 100                                           = '||round((sum(reloads) / sum(pins) *  
100),2)||'%' 
from    v$librarycache  
/  

prompt Increase memory until RELOADS is near 0 but watch out for  
prompt Paging/swapping 
prompt To increase library cache, increase SHARED_POOL_SIZE  
prompt  
prompt ** NOTE: Increasing SHARED_POOL_SIZE will increase the SGA size.  
prompt  
prompt Library Cache Misses indicate that the Shared Pool is not big  
prompt enough to hold the shared SQL area for all concurrently open cursors.  
prompt If you have no Library Cache misses (PINS = 0), you may get a small  
prompt increase in performance by setting CURSOR_SPACE_FOR_TIME = TRUE which  
prompt prevents ORACLE from deallocating a shared SQL area while an  
prompt application  
prompt cursor associated with it is open.  
prompt  
prompt For Multi-threaded server, add 1K to SHARED_POOL_SIZE per user.  
prompt  
prompt------------------------------------------------------------------------

column pdr      format 999.99  heading 'Pct_Tot_Disk_Reads'  
column pbg       format 999.99    heading 'Pct_Tot_Buff_Gets'
column prp       format 999.99    heading 'Pct_Tot_Rows_proc'
column pex       format 999.99    heading 'Pct_Tot_Execs'  
column text      format a40       heading 'SQL Text'  
column readex   format 99999999  heading 'Reads_per|Exec' 
column getsex  format 99999999  heading 'Gets_per|Exec'
  
column xpdr1 new_value xxpdr1 noprint
column xpbg1 new_value xxpbg1 noprint
column xprp1 new_value xxprp1 noprint
column xpex1 new_value xxpex1 noprint
 

prompt ====================================================================
prompt SQL Burners
prompt ====================================================================
prompt 

select                                               
sum(EXECUTIONS) xpex1                                            
,sum(DISK_READS) xpdr1            
,sum(BUFFER_GETS) xpbg1           
,sum(ROWS_PROCESSED) xprp1         
from v$sqlarea  
/  

set heading on

select sql_text text,
  round((sum(executions)/&xxpex1)*100,2) pex,
  round((sum(disk_reads)/&xxpdr1)*100,2) pdr,
  round((sum(buffer_gets)/&xxpbg1)*100,2) pbg,
  round((sum(rows_processed)/&xxprp1)*100,2) prp 
from   v$sqlarea
having (round((sum(disk_reads)/&xxpdr1)*100,2) > 5 
or round((sum(buffer_gets)/&xxpbg1)*100,2) > 5) 
and (round((sum(executions)/&xxpex1)*100,2) <= 1)
group by sql_text 
order  by sql_text 
/  

set heading off

prompt  
prompt------------------------------------------------------------------------
prompt 

column dictget format 999.99 heading 'Dictionary Get| Ratio %'
column dictscan format 999.99 heading 'Dictionary Scan| Ratio %'    

prompt ====================================================================
prompt Data Dictionary Cache 
prompt ====================================================================
prompt 

prompt  

set heading on

select 
(sum(scanmisses) / (sum(scans)+0.00000000001)) * 100 dictscan,  
(sum(getmisses) / (sum(gets)+0.00000000001)) * 100 dictget 
from   v$rowcache  
/  
 
set heading off

prompt  
prompt Look at scan hit ratio and get hit ratio 
prompt Any ratio more than 10% is not acceptable 
prompt Increase the SHARED_POOL_SIZE init.ora parameter
prompt------------------------------------------------------------------------  

column xv1 new_value xxv1 noprint  
column xv2 new_value xxv2 noprint  

prompt ====================================================================
prompt Hit Ratio
prompt ====================================================================
prompt  
prompt Values Hit Ratio is calculated against:  
prompt  

select lpad(name,20,' ')||'  =  '||value  
from   v$sysstat  
where  name in ('db block gets', 
                'consistent gets',
                'physical reads') 
/  

prompt Logical reads = db block gets + consistent gets
 

prompt Hit Ratio = (logical reads - physical reads) / logical reads

select lpad('Hit Ratio  ',24,' ')||'  =  ',
round( ((
  sum(decode(a.name,'db block gets',value,.00000000001)) +  
  sum(decode(a.name,'consistent gets',value,0)) ) -
 sum(decode(a.name,'physical reads',value,0))) /  
(sum(decode(a.name,'db block gets',value,.00000000001)) +  
  sum(decode(a.name,'consistent gets',value,0))) * 100,2),'%'
from   v$sysstat a  
/  
  

 
prompt If the hit ratio is less than 60%-70%, increase the initialization  
prompt parameter DB_BLOCK_BUFFERS.  
prompt ** NOTE:  Increasing this parameter will increase the SGA size.    
prompt------------------------------------------------------------------------  


column value format 999,999,999 
column psm       format 999.99  heading 'Pct_Sort_Mem' 

prompt ====================================================================
prompt Sort Area Size
prompt ====================================================================
prompt 

select 'INIT.ORA sort_area_size: '||value  
from    v$parameter  
where   name like 'sort_area_size' 
/ 
  
select name,value 
from v$sysstat 
where name like 'sort%'
/  
 
select 
 	lpad('Sort Area Ratio ',24,' ')||'  =  ',
       round((sum(decode(a.name,'sorts (memory)',value,0)) / 
       (sum(decode(a.name,'sorts (memory)',value,0)) + 
       sum(decode(a.name,'sorts (disk)',value,0))))*100,2) psm 
,'%' 
from   v$sysstat a  
/  

prompt  
prompt To make best use of sort memory, the initial extent of your Users  
prompt sort-work Tablespace should be sufficient to hold at least one sort  
prompt run from memory to reduce dynamic space allocation.  
prompt
prompt 90% of all sorts need to be done in memory
prompt
prompt If you are getting a high ratio of disk sorts as opposed to memory sorts, setting  
prompt sort_area_retained_size = 0 in init.ora will force the sort area to be  
prompt released immediately after a sort finishes.  
prompt  
prompt Note : This is allocated per user and taken from available memory
prompt        and not from the SGA

prompt  
prompt -----------------------------------------------------------------  
 
prompt ********************************************************************
prompt                             I/O
prompt ********************************************************************
prompt

  
col name format a30  
col gets format 9,999,999  
col waits format 9,999,999  
 
prompt ====================================================================
prompt Rollback Contention Statistics
prompt ====================================================================
prompt 

prompt  
  
prompt GETS  - # of gets on the rollback segment header 
prompt WAITS - # of waits for the rollback segment header 

select 'The average of waits/gets is '||  
   round((sum(waits) / sum(gets)) * 100,2)||'%'  
from    v$rollstat  
/  

prompt Rollbacks showing errors are

set heading on  
 
select name, waits, gets  
from   v$rollstat, v$rollname  
where  v$rollstat.usn = v$rollname.usn
and waits > gets/100  
/  
 
set heading off  
 
prompt  
prompt If the ratio of waits to gets is more than 1% or 2%, consider  
prompt creating more rollback segments  
prompt  
prompt Another way to gauge rollback contention is:  
prompt  

col class format a20  
column xn1 format 9999999  
column xv1 new_value xxv1 noprint  
 
set heading on  
 
select class, count  
from   v$waitstat  
where  class in ('system undo header', 'system undo block', 
                 'undo header',        'undo block'          )  
/  
 
set heading off  
 
select 'Total requests = '||sum(count) xn1, sum(count) xv1  
from    v$waitstat  
/  

Prompt Areas showing contention are

select lpad(class,18,' ')||' = '||  
       (round(count/(&xxv1+0.00000000001),4)) * 100||'%'  
from  v$waitstat  
where  class in ('system undo header', 'system undo block', 
                 'undo header',        'undo block'    )
and count > &xxv1/100
/  
 

 
prompt  
prompt If the percentage for an area is more than 1% or 2%, consider  
prompt creating more rollback segments.  Note:  This value is usually very  
prompt small 
prompt and has been rounded to 4 places.  
prompt  
prompt------------------------------------------------------------------------  
  
prompt ====================================================================
prompt Redo Contention Statistics
prompt ====================================================================
prompt 

prompt  

prompt  
prompt The following shows how often user processes had to wait for space in  
prompt the redo log buffer:  
  
select name||' = '||value  
from   v$sysstat  
where  name = 'redo log space requests'  
/  
 
prompt  
prompt This value should be near 0.  If this value increments consistently,  
prompt processes have had to wait for space in the redo buffer.  If this  
prompt condition exists over time, increase the size of LOG_BUFFER in the  
prompt init.ora file in increments of 5% until the value nears 0.  
prompt ** NOTE: increasing the LOG_BUFFER value will increase total SGA size.  
prompt  
prompt -----------------------------------------------------------------------  

col name format a15  
col gets format 9999999  
col misses format 9999999  
col immediate_gets heading 'IMMED GETS' format 9999999  
col immediate_misses heading 'IMMED MISS' format 9999999  
col sleeps format 999999  
 
  
prompt ====================================================================
prompt Latch Contention Statistics
prompt ====================================================================
prompt 

prompt  

prompt  
prompt GETS - # of successful willing-to-wait requests for a latch  
prompt MISSES - # of times an initial willing-to-wait request was unsuccessful  
prompt IMMEDIATE_GETS - # of successful immediate requests for each latch  
prompt IMMEDIATE_MISSES = # of unsuccessful immediate requests for each latch  
prompt SLEEPS - # of times a process waited and requests a latch after an  
prompt          initial willing-to-wait request  
prompt  
prompt If the latch requested with a willing-to-wait request is not  
prompt available, the requesting process waits a short time and requests  
prompt again.  
prompt If the latch requested with an immediate request is not available,  
prompt the requesting process does not wait, but continues processing  
prompt  
  
set head on  
 
select name,          gets,              misses,  
       immediate_gets,  immediate_misses,  sleeps  
from   v$latch  
where  name in ('redo allocation',  'redo copy')  
/  
 
set head off  
 
select 'Ratio of MISSES to GETS: '||  
        round((sum(misses)/(sum(gets)+0.00000000001) * 100),2)||'%'  
from    v$latch  
where   name in ('redo allocation',  'redo copy')  
/  
 
select 'Ratio of IMMEDIATE_MISSES to IMMEDIATE_GETS: '||  
        round((sum(immediate_misses)/  
       (sum(immediate_misses+immediate_gets)+0.00000000001) * 100),2)||'%'  
from    v$latch  
where   name in ('redo allocation',  'redo copy')  
/  
 
prompt  
prompt If either ratio exceeds 1%, performance will be affected.  
prompt  
prompt Decreasing the size of LOG_SMALL_ENTRY_MAX_SIZE reduces the number of  
prompt processes copying information on the redo allocation latch.  
prompt  
prompt Increasing the size of LOG_SIMULTANEOUS_COPIES will reduce contention  
prompt for redo copy latches.  
prompt------------------------------------------------------------------------  
  
column namespace    format a20   heading 'NAME'  
column gets         format 99999999 heading 'GETS'  
column gethits      format 99999999 heading 'GETHITS'  
column gethitratio  format 999.99   heading 'GET HIT|RATIO'  
column pins         format 9999999  heading 'PINHITS'  
column pinhitratio  format 999.99   heading 'PIN HIT|RATIO'  

prompt ====================================================================
prompt Library Cache Reloads
prompt ====================================================================
prompt 

prompt  

prompt  
prompt Look at gethitratio and pinhit ratio 
prompt Any ratio less than 80% is not acceptable 
prompt Increase the SHARED_POOL_SIZE init.ora parameter
 
prompt GETHITRATIO is number of GETHTS/GETS  
prompt PINHIT RATIO is number of PINHITS/PINS - number close to 1 indicates  
prompt that most objects requested for pinning have been cached.  Pay close  
prompt attention to PINHIT RATIO.  
prompt
prompt
prompt Unacceptable library cache ratio's are 


set heading on

select namespace,    gets,  gethits,  
       gethitratio,  pins,  pinhits, pinhitratio  
from   v$librarycache 
where (pinhitratio < 0.8 
 or   gethitratio < 0.8) 
/  

set heading off

prompt------------------------------------------------------------------------  
  

 
col event format a37 heading 'Event'  
col total_waits format 99999999 heading 'Total|Waits'  
col time_waited format 9999999999 heading 'Time Wait|In Hndrds'  
col total_timeouts format 999999 heading 'Timeout'  
col average_wait heading 'Average|Time' format 999999.999  
 

prompt ====================================================================
prompt System Events 
prompt ====================================================================
prompt 

prompt 
prompt Total waiting time longer than ten minutes
prompt 
prompt 

set heading on

select EVENT          
,TOTAL_WAITS    
,TOTAL_TIMEOUTS
,TIME_WAITED    
,AVERAGE_WAIT    
from   v$system_event
where time_waited > 60000 
order by TIME_WAITED desc  
/  

prompt 
prompt Events taking longer than a minute to complete
prompt 
prompt 


select EVENT          
,TOTAL_WAITS    
,TOTAL_TIMEOUTS
,TIME_WAITED    
,AVERAGE_WAIT    
from   v$system_event
where AVERAGE_WAIT > 100 
order by AVERAGE_WAIT desc  
/  

set heading off

prompt  
prompt------------------------------------------------------------------------  
  
  
column name        format a55            heading 'Statistic Name'  
column value       format 9,999,999,999  heading 'Result'  
column statistic#  format 9999           heading 'Stat#' 

prompt ====================================================================
prompt Instance Statistics
prompt ====================================================================
prompt 


 
prompt  
prompt  cumulative logons  
prompt(# of actual connections to the DB since last startup - good  
prompt  volume-of-use statistic)  
prompt  
prompt  #93  table fetch continued row  
prompt  (# of chained rows - will be higher if there are a lot of long fields   
prompt  if the value goes up over time, it is a good signaller of general   
prompt  database fragmentation)  
prompt  

select statistic#,  name,  value  
from   v$sysstat  
where  value > 0
and name in ('logons cumulative','table fetch continued row')  
/  
 
prompt  
prompt -----------------------------------------------------------------------  
 
column pcc   heading 'Parse|Ratio'       format 999.99  
column rcc   heading 'Recsv|Cursr'       format 999.99  
column hr    heading 'Buffer|Ratio'      format 999,999,999.999  
column rwr   heading 'Rd/Wr|Ratio'       format 999,999.9  
column bpfts heading 'Blks per|Full TS'  format 999.99 


select lpad('Parse Ratio  ',24,' ')||'  =  ',
round((sum(decode(a.name,'parse count',value,0)) /  
       sum(decode(a.name,'opened cursors cumulative',value,.00000000001)))*100,2) pcc,'%' 
from   v$sysstat a  
/

prompt
prompt Parse Ratio usually falls between 1.15 and 1.45.  If it is higher, then  
prompt it is usually a sign of poorly written Pro* programs or unoptimized  
prompt SQL*Forms applications.    
prompt

select lpad('Recursive Call Ratio ',24,' ')||'  =  ',
       round((sum(decode(a.name,'recursive calls',value,0)) /  
       sum(decode(a.name,'opened cursors cumulative',value,.00000000001))),2)  rcc  
from   v$sysstat a  
/  

prompt  
prompt Recursive Call Ratio will usually be between  
prompt  
prompt   7.0 - 10.0 for tuned production systems  
prompt  10.0 - 14.5 for tuned development systems  
prompt  
 

select 
 	lpad('Non-index Look-up Ratio ',24,' ')||'  =  ',
       round((sum(decode(a.name,'table scans (long tables)',value,.00000000001)) / 
       (sum(decode(a.name,'table scans (short tables)',value,0)) + 
       sum(decode(a.name,'table scans (long tables)',value,.00000000001))))*100,2) 
bpfts,'%'  
from   v$sysstat a  
/  

prompt  
prompt Non_index Look Up ratio indicates the percentage of 
prompt  table look ups that are full tablescans
prompt
prompt Typically this should be less than 40%
prompt

prompt  
prompt -----------------------------------------------------------------  

column pbr       format 999.99  heading 'Pct_Tot_Reads'  
column pbw       format 999.99    heading 'Pct_Tot_Writes'  
column name      format a40       heading 'Tsp Name'  
column readtim   format 99999999  heading 'Avg_Read|Time' 
column writetim  format 99999999  heading 'Avg_Write|Time'
  
column xpbr1 new_value xxpbr1 noprint
column xpbw1 new_value xxpbw1 noprint
column xtdf1 new_value xxtdf1 noprint   

prompt ====================================================================
prompt Tablespace I/O
prompt ====================================================================
prompt 

select sum(f.phyblkrd) xpbr1,sum(f.phyblkwrt) xpbw1,count(*) xtdf1
from   v$filestat f, v$datafile fs  
where  f.file#  =  fs.file#    
/  

set heading on

select ts.name name,  round((sum(f.phyblkrd)/&xxpbr1)*100,2) pbr,
                      round((sum(f.phyblkwrt)/&xxpbw1)*100,2) pbw, 
       avg(f.readtim),     avg(f.writetim)  
from   v$filestat f, v$datafile fs, v$tablespace ts 
where  f.file#  =  fs.file#
and    fs.ts# = ts.ts#
having (round((sum(f.phyblkrd)/&xxpbr1)*100,2) > 1
or round((sum(f.phyblkwrt)/&xxpbw1)*100,2) > 1) 
group by ts.name 
order  by ts.name  
/  

set heading off

prompt  
prompt Review list for unbalanced I/O activity 
prompt  
prompt I/O should be spread as evenly as possible
prompt 
prompt

prompt  
prompt -----------------------------------------------------------------  

column pbr       format 999.99  heading 'Pct_Tot_Reads'  
column pbw       format 999.99    heading 'Pct_Tot_Writes'
column lbr      format 999.99    heading 'Pct_Tot_Lreads' 

  
column xpbr1 new_value xxpbr1 noprint
column xpbw1 new_value xxpbw1 noprint
column xlbr1 new_value xxlbr1 noprint
 

prompt ====================================================================
prompt Object I/O
prompt ====================================================================
prompt 

select 
 sum(decode(statistic_name,'physical reads',value,0)) xpbr1
,sum(decode(statistic_name,'physical writes',value,0)) xpbw1
,sum(decode(statistic_name,'logical reads',value,0)) xlbr1
from v$segment_statistics
/

set heading on

select object_name
,round((sum(decode(statistic_name,'physical reads',value,0))/&xxpbr1)*100,2) pbr
,round((sum(decode(statistic_name,'physical writes',value,0))/&xxpbw1)*100,2) pbw
,round((sum(decode(statistic_name,'logical reads',value,0))/&xxlbr1)*100,2) lbr
from v$segment_statistics
having (round((sum(decode(statistic_name,'physical reads',value,0))/&xxpbr1)*100,2) > 1
or round((sum(decode(statistic_name,'physical writes',value,0))/&xxpbw1)*100,2) > 1
or round((sum(decode(statistic_name,'logical reads',value,0))/&xxlbr1)*100,2) > 1) 
group by object_name
order by object_name
/



prompt  
prompt -----------------------------------------------------------------  

column rownum noprint 

prompt ====================================================================
prompt Rollback Segments
prompt ====================================================================
prompt 

set heading on

select rownum,  extents,  rssize,  
       xacts,   gets,     waits,   writes,
	round((waits/gets)*100,2) rb_wait_ratio
from   v$rollstat 
where waits > (4 * gets)/100 
order  by rownum  
/  

set heading off
 
prompt  
prompt Identify any rollback wait ratios greater than 4%.
prompt  This will indicate rollback contention.
prompt Add additional private rollback segments if contention is spotted.
prompt 


prompt  
prompt -----------------------------------------------------------------  

prompt ********************************************************************
prompt                             Application
prompt ********************************************************************
prompt


col name format a40  
col value format a15


prompt ====================================================================
prompt Query Optimization Parameters
prompt ====================================================================

set heading on

prompt
prompt Optimiser Parameters
prompt

SELECT name, value 
FROM v$parameter 
WHERE name like 'optimizer%' 
ORDER BY name
/

prompt
prompt Parallel Operation Parameters
prompt

SELECT name, value 
FROM v$parameter 
WHERE name like 'parallel%' 
ORDER BY name
/

prompt
prompt DB Cache Parameters
prompt

SELECT name, value 
FROM v$parameter 
WHERE name like 'db%cache%' 
ORDER BY name
/

prompt
prompt Other Parameters
prompt

SELECT name, value 
FROM v$parameter 
WHERE name in ('cursor_sharing',
'db_file_multiblock_read_count',
'hash_area_size', 
'hash_join_enabled',
'query_rewrite_enabled',
'query_rewrite_integrity',
'sort_area_size', 
'star_transformation_enabled',
'bitmap_merge_area_size', 
'partition_view_enabled',
'pga_aggregate_target', 
'sga_max_size', 
'statistics_level', 
'workarea_size_policy' 
) 
ORDER BY name
/

prompt
prompt Oracle 8i to 9i Changes
prompt

SELECT name, value 
FROM v$parameter 
WHERE name in (
'buffer_pool_keep'
,'buffer_pool_recycle'
,'db_keep_cache_size'      
,'db_recycle_cache_size'   )
ORDER BY name
/

prompt
prompt BUFFER_POOL_KEEP and BUFFER_POOL_RECYCLE parameters, which will be deprecated in future versions. 
prompt Oracle recommends that you use DB_KEEP_CACHE_SIZE  & DB_RECYCLE_CACHE_SIZE instead.  
prompt

SELECT name, value 
FROM v$parameter 
WHERE name in ('db_block_buffers','db_cache_size')
ORDER BY name
/

prompt
prompt DB_BLOCK_BUFFERS parameter, which will be deprecated in future versions. 
prompt Oracle recommends that you use DB_CACHE_SIZE instead.  
prompt Note : DB_BLOCK_BUFFERS & DB_CACHE_SIZE cannot be set at the same time


set heading off


prompt  
prompt------------------------------------------------------------------------



prompt
prompt ====================================================================
prompt Invalid Objects
prompt ====================================================================

set heading on

select owner,object_type,object_name,status
from all_objects
where status != 'VALID'
order by 1,2
/

select owner,index_name,table_name,status
from all_indexes
where status != 'VALID'
order by 1,3,2
/

set heading off

prompt  
prompt -----------------------------------------------------------------  

prompt
prompt ====================================================================
prompt Disabled Constraints and Triggers
prompt ====================================================================

set heading on

select owner,constraint_name,constraint_type,status,delete_rule,r_constraint_name
from all_constraints
where status != 'ENABLED'
order by 1,2
/

select owner,trigger_name,'TRIGGER',status
from all_triggers
where status != 'ENABLED'
order by 1,2
/

set heading off

prompt  
prompt -----------------------------------------------------------------  

prompt ********************************************************************
prompt                             STATISTICS
prompt ********************************************************************
prompt

prompt
prompt ====================================================================
prompt Show enabled statistics or advisories
prompt ====================================================================

set heading on

select STATISTICS_NAME,DESCRIPTION            
from V$STATISTICS_LEVEL
where system_status = 'ENABLED'
order by STATISTICS_NAME
/

set heading off


prompt  
prompt -----------------------------------------------------------------  

prompt ====================================================================
prompt Show disabled statistics or advisories
prompt ====================================================================

set heading on

select STATISTICS_NAME,DESCRIPTION            
from V$STATISTICS_LEVEL
where system_status = 'DISABLED'
order by STATISTICS_NAME
/

set heading off


prompt  
prompt -----------------------------------------------------------------  




prompt
prompt ====================================================================
prompt Show dates objects where last analysed
prompt ====================================================================

set heading on

select to_char(LAST_ANALYZED,'YYYY-MM-DD') "Anlys Date",count(*) "no indexes"
from dba_indexes
group by to_char(LAST_ANALYZED,'YYYY-MM-DD')
order by to_char(LAST_ANALYZED,'YYYY-MM-DD')
/  

select to_char(LAST_ANALYZED,'YYYY-MM-DD') "Anlys Date",count(*) "no tables"
from dba_tables
group by to_char(LAST_ANALYZED,'YYYY-MM-DD')
order by to_char(LAST_ANALYZED,'YYYY-MM-DD')
/ 

set heading off


prompt
prompt
prompt
prompt ====================================================================
prompt END OF REPORT
prompt ====================================================================

spool off

exit
