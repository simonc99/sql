select rpad( '*', (level-1)*4, '*' ) || table_name table_name
from (select a.table_name, a.constraint_name pkey_constraint,
b.constraint_name fkey_constraint, null r_constraint_name
from dba_constraints a, dba_constraints b
Where a.owner=upper('&1')
and a.owner=b.owner and a.table_name=b.table_name
and a.constraint_type='P' and b.constraint_type='R'
Union All
select distinct t1.table_name child_table,null pkey_constraint,
t1.constraint_name  fkey_constraint,
t3.constraint_name r_constraint_name
from sys.dba_constraints t1,
sys.dba_constraints t2,dba_constraints t3
Where
t2.Table_Name = t3.Table_Name
and t3.constraint_type='R' and
t1.r_owner = upper('&1')
and t1.constraint_type = 'R'
and t1.r_constraint_name = t2.constraint_name
and t1.r_owner = t2.owner)
start with pkey_constraint is not null
connect by prior fkey_constraint = r_constraint_name
