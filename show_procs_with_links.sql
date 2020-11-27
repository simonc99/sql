set pagesize 999
set feedback off

select distinct owner,type,name
from
(
 select src.owner,src.type,name
     from sys.dba_source src
     where
     src.owner not in ('WKSYS','SYS','SYSTEM','CTXSYS','MDSYS',
	'ODM','OLAPSYS','ORDSYS','ORDPLUGINS','XDB')
     and
     src.text like '%@%'
union
 select src.owner,src.type,name
     from sys.dba_source src, sys.dba_synonyms syn
     where
     syn.owner='PUBLIC'
     and syn.db_link is not null
     and src.owner not in ('WKSYS','SYS','SYSTEM','CTXSYS','MDSYS',
	'ODM','OLAPSYS','ORDSYS','ORDPLUGINS','XDB')
     and src.text like '%'||syn.synonym_name||'%'
)
order by 1,2
/
