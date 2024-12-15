set lines 300
col duration for a10
col object for a32
break on username on sid on serial# on object_type
select a.username, a.sid, a.serial#, b.object_type, b.object_name OBJECT, b.subobject_name SUBOBJECT, 
decode(d.locked_mode,1,NULL,2,'Row Share',3,'Row Exclusive',4,'Share',5,'Shared Row Exclusive',6,'Exclusive',NULL) LOCK_MODE,
trunc(mod(24 * (sysdate - to_date(c.start_time, 'MM/DD/YY HH24:MI:SS')), 24))||':'||round(mod(60 * 24 * (sysdate - to_date(c.start_time, 'MM/DD/YY HH24:MI:SS')), 60)) DURATION
from
v$session a, dba_objects b, v$transaction c, v$locked_object d
where a.taddr = c.addr and d.session_id = a.sid and b.object_id = d.object_id
order by a.sid
/
