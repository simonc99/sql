col table_name for a24
col partition_name for a10
break on table_name;
set linesize 200 pagesize 4000 trimout on
select table_name, partition_name, tablespace_name, num_rows
from dba_tab_partitions where table_owner = 'RETAILJ'
order by table_name, partition_name, tablespace_name;
clear breaks;
