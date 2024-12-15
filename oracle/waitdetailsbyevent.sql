select sample_time,program, session_id, session_state, event, seq#, sql_id, '0' || trim(to_char(p1,'XXXXXXXXXXXXXXXXX')) "p1raw", p3 from v$active_session_history
where sample_time > (sysdate - 1) and
event = 'enq: TM - contention'
order by sample_time
/
