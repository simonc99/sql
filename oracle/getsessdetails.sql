set lines 130 pages 3000 trimspool on trimout on long 250
col username for a14 trunc 
col sample_time for a25
col sql_text for a40 word_wrapped
select 
	a.event, a.sql_id, count(*) COUNT
--	a.sample_time, b.username, c.sql_id, c.sql_text
from 
	dba_hist_active_sess_history a
--	dba_users b,
--	dba_hist_sqltext c
where 
	a.snap_id between 
		(select min(e.snap_id) from dba_hist_snapshot e
			where to_char(e.begin_interval_time,'YYYYMMDD HH24') = '20110818 14')
		and
		(select min(f.snap_id) from dba_hist_snapshot f
			where to_char(f.end_interval_time,'YYYYMMDD HH24') = '20110818 17') and
--	a.user_id = b.user_id and
--	a.sql_id = c.sql_id and
	event like 'enq: TM%' 
--	program = 'dis51usr.exe'
group by a.event, a.sql_id
order by count(*);
