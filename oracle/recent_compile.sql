set linesize 1000
set trimspool on
column object_name format a31
column compiled format a20
column owner format a10
select owner, object_type, object_name, status, to_char(last_ddl_time,'HH24:MI:SS DD-MON-YYYY') "COMPILED" from dba_objects where last_ddl_time > (SYSDATE - 1);
