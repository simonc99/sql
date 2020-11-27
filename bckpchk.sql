set echo off verify off

accept DAYS_TO_CHECK DEFAULT 1 prompt "Days to check [1]: "
accept SID DEFAULT "%" prompt "Database [all]: "
accept ORDER DEFAULT "2,1" prompt "Order by [sid,jobid]: "

rem set pause off termout off
rem col fred new_value v_fred
rem select owner fred
rem   from sys.dba_tables
rem  where table_name='OBK_JOBS';
rem set pause on termout on

set linesize 180
rem set pagesize 1000
col Jobid for 999999
col SID for a8
col Host for a8
col Date for a8
col Start for a6
col Stop for a6
col Type for a23
col User format a10
col jtype format 999 

select 	j.jobid "Jobid",
	i.ora_sid "SID",
        j.obkhost "Host",
	to_char(j.jstart,'dd/mm/yy') "Date",
	to_char(j.jstart,'HH24:MI') "Start",
	to_char(j.jstop,'HH24:MI') "Stop",
        decode(j.jtype,1,'Register',
		2,'Full Cold Backup',
		3,'Full Hot Backup',
		4,'Partial Hot Backup',
		6,'Full Restore',
		7,'Offline Restore',
		8,'Partial Restore',
		16,'Catalogue Backup',
		19,'Full Hot Backup',
		20,'Ctrlfile/Archive Backup',
		18,'Cold Backup',
		j.jtype) "Type",
	decode(j.state,
		'S','Successful..',
		'P','.In Progress',
		'I','.Invalidated',
		'T','........Test',
		'F','......Failed',
		j.state) "State",
	j.username "User"
from 	ebu.obk_jobs j,
	ebu.obk_inst_conf i
where	j.inst_cid = i.inst_cid(+)
and	j.jstart > (sysdate - &days_to_check)
and	i.ora_sid like '&SID'
order by &ORDER
/
