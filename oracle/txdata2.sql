col object_name for a32
col username for a12
set lines 150
break on username on sid on serial#
select a.username, a.sid, a.serial#, b.object_type, b.object_name, b.subobject_name, d.locked_mode, sysdate - to_date(c.start_time, 'MM/DD/YY HH24:MI:SS') DURATION
from v$session a, dba_objects b, v$transaction c, v$locked_object d
where a.taddr = c.addr and d.session_id = a.sid and b.object_id = d.object_id
order by a.sid;
