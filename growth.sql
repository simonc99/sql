column "Percent of Total Disk Usage" justify right format 999.99
column "Space Used (MB)" justify right format 9,999,999.99
column "Total Object Size (MB)" justify right format 9,999,999.99
set linesize 150
set pages 80
set feedback off

select * from (select to_char(end_interval_time, 'MM/DD/YY') mydate, sum(space_used_delta) / 1024 / 1024 "Space used (MB)", avg(c.bytes) / 1024 / 1024 "Total Object Size (MB)", 
round(sum(space_used_delta) / sum(c.bytes) * 100, 2) "Percent of Total Disk Usage"
from 
dba_hist_snapshot sn, 
dba_hist_seg_stat a, 
dba_objects b, 
dba_segments c
where begin_interval_time > trunc(sysdate) - &days_back
and sn.snap_id = a.snap_id
and b.object_id = a.obj#
and b.owner = c.owner
and b.object_name = c.segment_name
and c.segment_name = '&segment_name'
group by to_char(end_interval_time, 'MM/DD/YY'))
order by to_date(mydate, 'MM/DD/YY');

