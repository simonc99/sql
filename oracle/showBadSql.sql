prompt
prompt Show Bad SQL
prompt ============

set pagesize 2000
col sql_text form a30

select hash_value, address, executions, disk_reads, disk_reads/executions, sql_text 
from V$SQLAREA A 
where A.executions > 1 
and disk_reads/executions > 20
order by disk_reads/executions desc
/
