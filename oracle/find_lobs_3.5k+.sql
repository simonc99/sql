set pages 4000 lines 4000 trimspool on trimout on heading off feedback off
spool findlob.sql
select 'select count(*) from '||a.OWNER||'.'||a.TABLE_NAME||' where dbms_lob.getlength('||column_name||') > 3880;' from
dba_tables a, dba_lobs b where a.table_name = b.table_name and a.owner = 'TRENTADM' and a.num_rows > 0;
spool off
