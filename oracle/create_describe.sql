-- Describe ALL tables (except SYS / SYSTEM)
-- SCC 17th February 2000
--
set heading off
set feedback off
set linesize 4000
set trimspool on
set termout off
spool c:\dynam.sql
select 'prompt '||owner||'.'||table_name||'
describe '||owner||'.'||table_name||';' from dba_tables where owner not in ('SYS','SYSTEM')
	order by owner, table_name;
spool off
spool c:\table_descriptions.txt
@c:\dynam.sql
spool off
host del c:\dynam.sql
set heading on
set feedback on
set termout on
