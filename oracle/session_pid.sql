select
        s.username,
        s.sid,
        s.serial#,
        s.status,
        lpad(p.spid,6) spid
from v$session s, v$process p
where s.username is not null
        and p.addr = s.paddr
order by username, sid;
