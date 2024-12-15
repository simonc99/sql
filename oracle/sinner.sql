rem
rem	Script:		sinner.sql
rem	Author:		J.P.Lewis
rem	Last Update:	01-June-1998
rem	Purpose:	Get recent SQL Text and Cost for a Unix PID
rem
rem	Input variables:
rem		Unix process id (of a PQ slave or oracle{SID} process)
rem
rem	Usage:
rem		start sinner {UNIX pid}
rem		start sinnger 28120
rem
rem	Notes:
rem	For performance reasons the code runs in steps rather then
rem	using a simple join.  (Apart from the v$session/process bit
rem	where there are no useful pseudo-indexed columns).
rem
rem	The use of UNION ALLs instead of a simple OR is for the same reason
rem

define m_pid=&1

clear breaks
clear columns
set verify off
set pagesize 22

column sql_address	new_value m_sql_addr noprint
column sql_hash_value	new_value m_sql_hash noprint format 9999999999999999
column prev_sql_addr	new_value m_prev_addr noprint
column prev_hash_value	new_value m_prev_hash noprint format 9999999999999999

column logon_time format a14

select
	ses.sid, ses.username, ses.osuser,
	to_char(ses.logon_time,'dd-mon hh24:mi') logon_time,
	ses.sql_address, ses.sql_hash_value,
	ses.prev_sql_addr, ses.prev_hash_value
from
	v$session	ses,
	v$process	pro
where	ses.paddr = pro.addr
and	pro.spid = &m_pid
;

column which format a9
break on which skip 1

rem	===================================================
rem
rem	This gets the cost, use, and first 2,000 characters
rem
rem	===================================================

select
	'Current'	which,
	executions,
	parse_calls,
	sorts,
	buffer_gets,
	disk_reads,
	hash_value,
	sql_text
from
	v$sqlarea
where
	hash_value = &m_sql_hash
and 	address = '&m_sql_addr'
UNION ALL
select
	'Previous'	which,
	executions,
	parse_calls,
	sorts,
	buffer_gets,
	disk_reads,
	hash_value,
	sql_text
from
	v$sqlarea
where
	hash_value = &m_prev_hash
and 	address = '&m_prev_addr'
;

rem	========================
rem
rem	This gets the whole text
rem
rem	========================

column piece noprint

select
	'Current'	which,
	piece,
	sql_text 
from	v$sqltext
where	hash_value = &m_sql_hash
and	address = '&m_sql_addr'
UNION ALL
select
	'Previous'	which,
	piece,
	sql_text 
from	v$sqltext
where	hash_value = &m_prev_hash
and	address = '&m_prev_addr'
order by 
	1,2
;
