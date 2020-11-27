select distinct
s.sid, s.username, s.osuser, s.program||' '||s.module program,
s.status, s.last_call_Et/60 minutes, s.logon_time, w.state, w.event, w.seconds_in_wait ,
q.sql_text
from v$session s, v$sql q, v$session_wait w
where ( s.status = 'ACTIVE' or last_call_et < 60 )
and s.sql_hash_value = q.hash_value
and s.sql_address = q.address
and s.sid = w.sid
order by s.sid
/
