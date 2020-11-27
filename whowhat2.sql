select a.username, a.sql_hash_value, b.object from
v$session a, v$access b where
a.sid = b.sid and
a.status = 'ACTIVE' and
a.username is not null and
b.owner = 'RETAILJ'
