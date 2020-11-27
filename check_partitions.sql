set lines 300 trimspool on trimout on pages 4000

select TABLE_NAME, PARTITION_NAME, TABLESPACE_NAME from
dba_tab_partitions where
table_owner = 'RETAILJ' order by table_name, partition_name;

select table_name, lob_name, PARTITION_NAME, LOB_PARTITION_NAME, TABLESPACE_NAME, CHUNK
from dba_lob_partitions where table_owner = 'RETAILJ' order by table_name, PARTITION_NAME;

select index_name, PARTITION_NAME, TABLESPACE_NAME
from dba_ind_partitions where index_owner = 'RETAILJ'
order by index_name, partition_name;

