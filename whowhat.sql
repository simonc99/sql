select a.username "User", b.spid "PID", a.sid, c.sql_text "SQL Text" from
v$session a, v$process b, v$sqlarea c
where
a.paddr = b.addr and
a.sql_hash_value = c.hash_value
and a.status = 'ACTIVE' and
a.username is not null
and a.sid != (select distinct sid from v$mystat)
order by a.username
/
