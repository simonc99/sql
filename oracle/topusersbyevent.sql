set pages 4000
break on event skip page
select b.event, a.username, count(*) from dba_users a, v$active_session_history b where
b.sample_time > (sysdate - 1)
and a.user_id = b.user_id and b.event is not null and b.event not like 'db file%'
group by b.event, a.username
order by event, count(*)
/
