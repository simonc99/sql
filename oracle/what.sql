break on username on sid on status
select s.username, s.sid,s.status,q.sql_text
from v$session s,v$sqltext q
where s.sql_hash_value=q.hash_value
and s.sql_address=q.address
and s.username=upper('&1')
order by piece
/
