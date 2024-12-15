set lines 130 pages 3000 trimspool on trimout on
col event for a32 trunc 
select event, sql_id, count(*) from dba_hist_active_sess_history
where snap_id between 
	(select min(snap_id) from dba_hist_snapshot) and
	(select max(snap_id) from dba_hist_snapshot)
and event like
	'enq: TM%'
-- and user_id = (select user_id from dba_users where username = 'SARGENTA')
group by event, sql_id
order by count(*);
