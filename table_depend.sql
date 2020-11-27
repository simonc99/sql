set serveroutput on
set trimsp on
set ver off

CREATE TABLE tables_dependencies
(root_table VARCHAR2(30),
node_table VARCHAR2(30),
rank NUMBER,
parent_rank NUMBER)
/

-- following lines give only ROOT tables (those
-- that don't have PK-pointing foreign keys)
-- (uncomment them not: this is a reminder)
-- + select table_name
-- + from dba_constraints c1
-- + where owner='&&1'
-- + and constraint_type='P'
-- + and not exists (select NULL
-- + from dba_constraints c3
-- + where -- c1.constraint_name =
-- + c3.r_constraint_name
-- + c1.owner = c3.r_owner
-- + and c1.table_name = c3.table_name
-- + --
-- + and c3.constraint_type = 'R')

-- step 1
prompt 2nd argument = TABLE_NAME (optional)
INSERT INTO tables_dependencies
SELECT c1.table_name,
c2.table_name,
1, NULL
FROM dba_constraints c1,
dba_constraints c2
WHERE c1.owner = UPPER('&&1') -- 'EXT528'
and c1.table_name LIKE UPPER('%&&2%')
AND c1.constraint_type = 'P'
AND c1.constraint_name = c2.r_constraint_name
AND c1.owner = c2.r_owner
--
-- if following lines removed, you get all schema's tables
-- that have FK dependencies pointing towards them (and not
-- only 'root' tables of the tree-structure)
AND NOT EXISTS (SELECT NULL
FROM dba_constraints c3
WHERE c1.owner = c3.r_owner
AND c1.table_name = c3.table_name
AND c3.constraint_type = 'R');
--
-- following line gotta be removed against 7.* versions:
-- ORDER BY 1, 2;

-- step L_RANK's
-- (remark: the RANK column is the equivalent of the LEVEL
-- pseudo-column)
DECLARE
l_cnt NUMBER := 0;
l_rank NUMBER := 1;
BEGIN

SELECT COUNT(DISTINCT table_name) INTO l_cnt
FROM dba_constraints c,
tables_dependencies td
WHERE c.table_name = td.node_table
AND c.constraint_type = 'P'
and c.owner = UPPER('&&1')
AND td.rank = l_rank;

WHILE l_cnt > 0 LOOP

l_rank := l_rank + 1;
dbms_output.put_line('level = '||l_rank||' of depth, inserting '||l_cnt||' rows.');

INSERT INTO tables_dependencies
SELECT c1.table_name root_table,
c2.table_name node_table,
l_rank, l_rank - 1
FROM dba_constraints c1,
dba_constraints c2
WHERE c1.owner = UPPER('&&1')
AND c1.constraint_type = 'P'
AND c1.constraint_name = c2.r_constraint_name
AND c1.owner = c2.r_owner
AND EXISTS (SELECT NULL
FROM tables_dependencies td
WHERE c1.table_name = td.node_table
AND td.rank = l_rank-1)
AND NOT EXISTS (SELECT NULL
FROM tables_dependencies td
WHERE c1.table_name = td.root_table);
-- AND td.rank = l_rank-1);

SELECT COUNT(DISTINCT table_name) INTO l_cnt
FROM dba_constraints c,
tables_dependencies td
WHERE c.table_name = td.node_table
AND c.constraint_type = 'P'
AND c.owner = UPPER('&&1')
AND rank = l_rank;
END LOOP;

END;
/

-- output step
col root_table format a25
col node_table format a25
set pages 100
set lines 90

break on rank skip 1 on root_table

spool tree2
SELECT *
FROM tables_dependencies
ORDER BY rank, root_table, node_table
/
spool off

spool tree2primKeysCnt
select root_table, count(1)
from tables_dependencies
group by root_table
order by 2
/
spool off

spool tree2foreignKeysCnt
select node_table, count(1)
from tables_dependencies
group by node_table
order by 2
/
spool off

-- echo "Show all occurences of: c"
-- read tabName
-- grep $tabName tree2.lst
--
-- echo "Show PRIM. KEY occurences of: $tabName"
-- grep "^$tabName" tree2.lst
--
-- echo "Show FOREIGN KEY occurences of $tabName"
-- grep "^......................... $tabName" tree2.lst
--
-- echo "$tabName appears N times as PARENT table:"
-- grep "$tabName" tree2primKeysCnt.lst
--
-- echo "$tabName appears N times as CHILD table:"
-- grep "$tabName" tree2foreignKeysCnt.lst
--

DROP TABLE TABLES_DEPENDENCIES
/
