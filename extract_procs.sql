set heading off
set feedback off
set termout off
set linesize 1000
set trimspool on

select distinct 'spool '||type||'/'||name||'.SQL
select text from dba_source where name = -
'''||name||''' and owner = ''DDMAST'' - 
and type = '''||type||''' -
order by line;' from dba_source;
