set echo off feedback off heading off lines 400 trimspool on trimout on pages 4000
spool llobs.sql
select 'select '''||a.table_name||' has '||a.num_rows||''', count(*) from '||a.OWNER||'.'||a.TABLE_NAME||' where dbms_lob.getlength('||column_name||') > 3880;' from
dba_tables a, dba_lobs b where a.table_name = b.table_name and a.owner = 'QUERCUS' and a.num_rows > 0;
spool off
