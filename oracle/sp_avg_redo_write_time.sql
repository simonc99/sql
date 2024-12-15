/**********************************************************************
 * File:        sp_avg_redo_write_time.sql
 * Type:        SQL*Plus script
 * Author:      Tim Gorman (Evergreen Database Technologies, Inc.)
 * Date:        14-Feb-2005
 *
 * Description:
 *	Query to show average write time to online redo logs on a
 *	day-by-day as well as an hour-by-hour basis over time, using
 *	data in the STATSPACK repository...
 *
 * Modifications:
 *********************************************************************/
set pagesize 100 linesize 80 trimout on trimspool on verify off pause off
set echo off feedback off timing off
col sort0 noprint
col day heading "Day"
col hr heading "Hour"
col sum_redo_writes format 999,999,990.00 heading "Sum # Redo|Write I/O Rqsts"
col sum_redo_write_time format 999,990.00 heading "Sum|Redo Write|Time (secs)"
col avg_redo_writes format 999,999,990.000 heading "Avg # Redo|Write I/O Rqsts|Per Sec"
col avg_redo_write_time format 990.00000000 heading "Avg|Redo Write|I/O Rqst|Time (secs)"

accept V_INSTANCE_NAME prompt "ORACLE_SID value (wildcards permitted): "
accept V_NBR_DAYS prompt "How many days of data to examine? "

spool sp_avg_redo_write_time

clear breaks computes
break on report
compute sum of sum_redo_writes on report
compute sum of sum_redo_write_time on report
compute avg of avg_redo_write_time on report
compute avg of avg_redo_writes on report
ttitle center 'Average Redo Write Time - Daily Summary' skip 1 line

select	to_char(s.snap_time, 'YYYYMMDD') sort0,
	to_char(s.snap_time, 'DD-MON') day,
	sum(w.value) sum_redo_writes,
	sum(t.value) sum_redo_write_time,
	avg(w.value / t.value) avg_redo_writes,
	avg(t.value / w.value) avg_redo_write_time
from	(select	dbid,
		instance_number,
		snap_id,
		decode(greatest(value, lag(value,1,0) over (partition by dbid,
									 instance_number
							    order by snap_id)),
			value,
			value - lag(value,1,0) over (partition by dbid,
								  instance_number
						     order by snap_id),
			value)/100 value
	 from	stats$sysstat
	 where	name = 'redo write time')		t,
	(select	dbid,
		instance_number,
		snap_id,
		decode(greatest(value, lag(value,1,0) over (partition by dbid,
									 instance_number
							    order by snap_id)),
			value,
			value - lag(value,1,0) over (partition by dbid,
								  instance_number
						     order by snap_id),
			value) value
	 from	stats$sysstat
	 where	name = 'redo writes')			w,
	(select	distinct dbid, instance_number
	 from	stats$database_instance
	 where	instance_name like '&&V_INSTANCE_NAME')	i,
	stats$snapshot					s
where	w.dbid = i.dbid
and	w.instance_number = i.instance_number
and	t.dbid = i.dbid
and	t.instance_number = i.instance_number
and	s.dbid = i.dbid
and	s.instance_number = i.instance_number
and	s.snap_time between trunc(sysdate - &&V_NBR_DAYS) and sysdate
and	w.snap_id = s.snap_id
and	t.snap_id = s.snap_id
and	w.value > 0
and	t.value > 0
group by to_char(s.snap_time, 'YYYYMMDD'),
	 to_char(s.snap_time, 'DD-MON')
order by sort0;

clear breaks computes
break on day skip 1 on report
compute sum of sum_redo_writes on day
compute sum of sum_redo_write_time on day
compute avg of avg_redo_write_time on day
compute avg of avg_redo_writes on day
ttitle center 'Average Redo Write Time - Hourly Summary' skip 1 line

select	to_char(s.snap_time, 'YYYYMMDDHH24') sort0,
	to_char(s.snap_time, 'DD-MON') day,
	to_char(s.snap_time, 'HH24')||':00' hr,
	sum(w.value) sum_redo_writes,
	sum(t.value) sum_redo_write_time,
	avg(w.value / t.value) avg_redo_writes,
	avg(t.value / w.value) avg_redo_write_time
from	(select	dbid,
		instance_number,
		snap_id,
		decode(greatest(value, lag(value,1,0) over (partition by dbid,
									 instance_number
							    order by snap_id)),
			value,
			value - lag(value,1,0) over (partition by dbid,
								  instance_number
						     order by snap_id),
			value)/100 value
	 from	stats$sysstat
	 where	name = 'redo write time')		t,
	(select	dbid,
		instance_number,
		snap_id,
		decode(greatest(value, lag(value,1,0) over (partition by dbid,
									 instance_number
							    order by snap_id)),
			value,
			value - lag(value,1,0) over (partition by dbid,
								  instance_number
						     order by snap_id),
			value) value
	 from	stats$sysstat
	 where	name = 'redo writes')			w,
	(select	distinct dbid, instance_number
	 from	stats$database_instance
	 where	instance_name like '&&V_INSTANCE_NAME')	i,
	stats$snapshot					s
where	w.dbid = i.dbid
and	w.instance_number = i.instance_number
and	t.dbid = i.dbid
and	t.instance_number = i.instance_number
and	s.dbid = i.dbid
and	s.instance_number = i.instance_number
and	s.snap_time between trunc(sysdate - &&V_NBR_DAYS) and sysdate
and	w.snap_id = s.snap_id
and	t.snap_id = s.snap_id
and	w.value > 0
and	t.value > 0
group by to_char(s.snap_time, 'YYYYMMDDHH24'),
	 to_char(s.snap_time, 'DD-MON'),
	 to_char(s.snap_time, 'HH24')||':00'
order by sort0;

spool off
ttitle off




