col "SQL Text" for a30 word_wrapped
col "Bind Value(s)" for a20 word_wrapped
col "User" for a9
col PID for 999
select a.username "User", b.spid "PID", c.sql_text "SQL Text", d.value_string "Bind Value(s)" from
v$session a, v$process b, v$sqlarea c, v$sql_bind_capture d
where
a.paddr = b.addr and
a.sql_hash_value = c.hash_value and
d.sql_id = a.sql_id and
and a.status = 'ACTIVE' and
a.username is not null
and a.sid != (select distinct sid from v$mystat)
order by a.username
/
