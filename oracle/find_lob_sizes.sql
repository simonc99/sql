set linesize 400
select 'select ''TABLE : '||a.table_name||' HAS '','''||b.num_rows||' ROWS, WITH AN AVG LOB SEGMENT SIZE OF '', avg(dbms_lob.getlength('||a.column_name||')) bytes from TRENTADM.'||a.table_name||';'
from dba_lobs a, dba_tables b where
a.owner = 'TRENTADM' and
a.table_name = b.table_name and
b.num_rows > 0
/
