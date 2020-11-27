set pagesize 5000

prompt****************************************************
prompt Hit Ratio Section 
prompt****************************************************
prompt 
prompt  ========================= 
prompt  BUFFER HIT RATIO 
prompt  ========================= 
prompt (should be > 70, else increase db_block_buffers in init.ora) 

column "logical_reads" format 99,999,999,999 
column "phys_reads" format 999,999,999 
column "phy_writes" format 999,999,999 

select a.value + b.value "logical_reads", 
                c.value   "phys_reads", 
                d.value   "phy_writes", 
                round(100 * ((a.value+b.value)-c.value) / (a.value+b.value)) 
                "BUFFER HIT RATIO" 
from v$sysstat a, v$sysstat b, v$sysstat c, v$sysstat d 
where a.statistic# = 37 and b.statistic# = 38 and c.statistic# = 39 and d.statistic# = 40; 
prompt 
prompt  ========================= 
prompt  DATA DICT HIT RATIO 
prompt  ========================= 
prompt (should be higher than 90 else increase shared_pool_size in init.ora) 
prompt 
column "Data Dict. Gets"   format 999,999,999 
column "Data Dict. cache misses" format 999,999,999 
select sum(gets) "Data Dict. Gets", sum(getmisses) "Data Dict. cache misses", trunc((1-(sum(getmisses)/sum(gets)))*100) "DATA DICT CACHE HIT RATIO" 
from v$rowcache; 
prompt 
prompt  ========================= 
prompt  LIBRARY CACHE MISS RATIO 
prompt  ========================= 
prompt (If > .1, i.e., more than 1% of the pins resulted in reloads, then increase the shared_pool_size in init.ora) 
prompt 
column "LIBRARY CACHE MISS RATIO" format 99.9999 
column "executions" format 999,999,999 
column "Cache misses while executing" format 999,999,999 

select sum(pins) "executions", sum(reloads) "Cache misses while executing", (((sum(reloads)/sum(pins)))) "LIBRARY CACHE MISS RATIO" 
from v$librarycache; 

prompt 
prompt  ========================= 
prompt  Library Cache Section 
prompt  ========================= 
prompt hit ratio should be > 70, and pin ratio > 70 ... 
prompt 

select namespace, trunc(gethitratio * 100) "Hit ratio", trunc(pinhitratio * 100) "pin hit ratio", reloads "reloads" 
from v$librarycache; 

