select 'grant '||privilege||' on '||owner||'.'||table_name||' to '||grantee||';' from dba_tab_privs where
owner = upper('&owner')
/
