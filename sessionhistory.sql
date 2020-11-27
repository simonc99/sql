set lines 200 pages 4000
col sql_fulltext for a80 word_wrapped
col sample_time for a25
col event for a25 trunc
break on sample_time skip page
select b.sample_time, c.username, a.sql_id, a.sql_fulltext, b.event, b.blocking_session from
v$sql a, v$active_session_history b, dba_users c where
a.sql_id = b.sql_id and b.user_id = c.user_id and
-- c.username = 'SARGENTA'
-- b.session_id = 1278
-- b.program = 'dis51usr.exe'
-- b.sql_id = 'g2bw0ahbj618h'
-- b.event like 'enq: TX%'
b.event like 'enq: TM%'
-- b.module = 'APEX:APPLICATION 1003'
order by b.sample_time;
