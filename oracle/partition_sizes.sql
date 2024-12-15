select substr(partition_name,17,8), sum(bytes)/1024/1024 from
dba_segments where partition_name like 'GSMCDR_ALL_TYPES200308%'
group by substr(partition_name,17,8)
