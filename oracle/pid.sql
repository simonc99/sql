select t.sql_text, s.sid, s.serial#, s.username, p.pid, p.spid
from
	v$process p,
	v$session s,
	v$sqltext t
where
	spid = '&PID' and
	s.paddr = p.addr and
	t.address = s.sql_address and
	t.hash_value = s.sql_hash_value
order by piece;
