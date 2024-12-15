col machine for a14 trunc
select s.sid,s.serial#,p.spid,s.machine,m.allocated/1024/1024 MB
from v$session s, v$process p, v$process_memory m
where s.paddr = p.addr and p.pid = m.pid
order by m.allocated
/
