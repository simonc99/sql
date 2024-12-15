set pages 9999;

column reads  format 999,999,999
column writes format 999,999,999

select 
   to_char(snap_time,'day'),
   avg(newreads.value-oldreads.value) reads,
   avg(newwrites.value-oldwrites.value) writes
from
   perfstat.stats$sysstat oldreads,
   perfstat.stats$sysstat newreads,
   perfstat.stats$sysstat oldwrites,
   perfstat.stats$sysstat newwrites,
   perfstat.stats$snapshot   sn
where
   newreads.snap_id = sn.snap_id
and
   newwrites.snap_id = sn.snap_id
and
   oldreads.snap_id = sn.snap_id-1
and
   oldwrites.snap_id = sn.snap_id-1
and
  oldreads.statistic# = 40
and 
  newreads.statistic# = 40
and 
  oldwrites.statistic# = 41
and
  newwrites.statistic# = 41
having
   avg(newreads.value-oldreads.value) > 0
and
   avg(newwrites.value-oldwrites.value) > 0
group by
   to_char(snap_time,'day')
order by
   to_char(snap_time,'day')
;
