set lines 4000 pages 4000 trimspool on trimout on
column username format a15 
column osuser format a15
select a.username, a.osuser, b.LOG_IO, b.PHY_IO, b.START_TIME, a.status 
from v$session a, v$transaction b where a.taddr = b.addr;
