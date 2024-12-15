set lines 160
col sample_time for a30
col event for a30 trunc
select b.sample_time, a.username, b.sql_id, b.event
from
dba_users a, v$active_session_history b
where
b.blocking_session = (select sid from v$session where program like '%LGWR%') and
trunc(sample_time) = '00:00:00 17-JUN-2011' and
a.user_id = b.user_id
order by 1
/
