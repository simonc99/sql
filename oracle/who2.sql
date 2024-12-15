----------------------------------------------------------------------
-- who2.sql
-- shows user info and server info if applicable

set recsep off term on pause off verify off echo off lines 142

col username heading 'USERNAME' format a10
col sessions heading 'SESSIONS'
col sid heading 'SID' format 9999
col status heading 'STATUS' format a10
col machine format a10 head 'MACHINE'
col client_program format a34 head 'CLIENT PROGRAM' truncate
col server_program format a30 head 'SERVER PROGRAM'
col spid format 9999999 head 'UNIX|PROC'
col serial# format 99999 head 'SERIAL#'
col logon format a12

set line 142
--set trimspool on

clear break
break on username skip 1

select
        s.username,
        s.sid,
        s.serial#,
        s.status,
        replace(s.machine,'STANDARD\') machine,
        s.program client_program,
        lpad(p.spid,7) spid,
        p.program server_program,
        to_char(s.logon_time,'YYMMDD HH24:MI') logon
from v$session s, v$process p
where s.username is not null
	and s.username like upper('%&1%')
        and p.addr = s.paddr
order by username, sid;

set recsep wrapped 

----------------------------------------------------------------------
