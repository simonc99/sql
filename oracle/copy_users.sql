set heading off
set feedback off
set pagesize 4000
set linesize 4000
set trimspool on
spool create_users.sql
select 'create user '||username||' identified by values '''||password||'''
default tablespace '||default_tablespace||'
temporary tablespace '||temporary_tablespace||'
profile default;' from dba_users where
username not in ('SYSTEM','SYS','DBSNMP','OASIS','CWISE')
and username not like 'ORA%'
and username not like 'JB1%';
spool off
