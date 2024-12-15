select 'analyze '||object_type||' '||owner||'.'||object_name||' estimate statistics sample 20 percent;' from dba_objects where owner in ('CWISE','OASIS') and object_type = 'TABLE' and object_name not like '%GMD%'
/
