column segment_name format a31
column segment_type format a13
column extents format 999999
select segment_name, segment_type, initial_extent, next_extent, extents from dba_segments where owner in
('CWISE','OASIS') and extents >= 3
and segment_name not like '%GMD%'
order by extents desc
/
