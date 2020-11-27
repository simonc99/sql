select a.segment_name, a.tablespace_name, a.next_extent from dba_segments a where
a.next_extent  > (select max(bytes) from dba_free_space where tablespace_name = 'UPLINK_DATA1')
/
