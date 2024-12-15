select to_char(a.snap_time,'YYYYMMDD HH24'), b.value from
perfstat.stats$snapshot a,
perfstat.stats$osstat b,
perfstat.stats$osstatname c
where
a.snap_id = b.snap_id and
b.osstat_id = c.osstat_id and
c.stat_name = 'LOAD'
order by 1
/
