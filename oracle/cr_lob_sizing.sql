set heading off feedback off lines 400 trimspool on trimout on pagesize 4000
spool /tmp/getlobsizes.sql
select 'set echo off heading off feedback off lines 80 trimspool on trimout on pagesize 4000' from dual;
select 'spool /tmp/lob_sizes.log' from dual;
select 'select '''||a.table_name||''', max(dbms_lob.getlength('''||a.segment_name||''')) BYTES from '||a.owner||'.'||a.table_name||';' from dba_lobs a, dba_tables b
where a.owner = 'QUERCUS' and a.table_name = b.table_name and b.num_rows > 0;
select 'spool off' from dual;
spool off
