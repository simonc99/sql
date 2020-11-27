set pagesize 0
set feedback off
col nl newline

spool fix_synonym_links.tmp
select 'prompt Fixing '||decode(owner,'PUBLIC','PUBLIC ',owner||'.')||synonym_name||' which uses '||db_link nl,
'drop '||decode(owner,'PUBLIC','PUBLIC SYNONYM ','SYNONYM ')||
decode(owner,'PUBLIC',synonym_name,owner||'.'||synonym_name) nl,
'/' nl,
'create '||decode(owner,'PUBLIC','PUBLIC SYNONYM ','SYNONYM ')||
decode(owner,'PUBLIC',synonym_name,owner||'.'||synonym_name) nl,
'for '||decode(table_owner,'',' ',table_owner||'.')||table_name
||'@'||
substr(db_link,1,instr(DB_LINK,'.')-1) nl,
'/' nl
from sys.dba_synonyms
where db_link is not null
/
spool off
