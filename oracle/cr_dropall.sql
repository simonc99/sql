set pagesize 4000
set linesize 4000
set trimspool on
set heading off
set feedback off
select 'alter table '||owner||'.'||table_name||' disable constraint '||constraint_name||';' from dba_constraints where owner in
(select owner from dba_objects where object_type = 'TABLE' and owner not
in ('SYS','SYSTEM','ORACLE') group by owner);
select 'alter table '||owner||'.'||table_name||' drop constraint '||constraint_name||';' from dba_constraints where owner in
(select owner from dba_objects where object_type = 'TABLE' and owner not
in ('SYS','SYSTEM','ORACLE') group by owner);
select 'drop '||object_type||' '||owner||'.'||object_name||';'
from dba_objects where owner in (
select owner from dba_objects where object_type != 'SYNONYM' and
owner not in ('SYS','SYSTEM','ORACLE') group by owner)
order by owner, object_type;
set feedback on
set heading on
