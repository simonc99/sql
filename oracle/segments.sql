column segment_name format a35
set lines 4000
set pages 4000
set verify off
select segment_name, segment_type, initial_extent, next_extent, extents, (((next_extent*extents)-next_extent)+initial_extent)/1024/1024 "ALLOCATED MB"
from dba_segments where owner = '&1' order by segment_type, segment_name; 
