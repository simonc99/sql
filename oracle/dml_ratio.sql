select a.table_name, b.num_rows, a.inserts, a.deletes, a.updates, ((a.inserts+a.updates+a.deletes)/b.num_rows) DML_RATIO
from all_tab_modifications a, dba_tables b where
a.table_name = b.table_name and
b.owner = 'TRENTADM'
and b.num_rows > 0
order by 6
/
