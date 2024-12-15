set lines 300 trimspool on trimout on pagesize 4000 heading off feedback off
spool move_LOB_segments.sql
select 'ALTER TABLE TRENTADM.'||table_name||' MOVE LOB('||b.segment_name||') STORE AS
'||substr(a.table_name,1,18)||'_'||substr(a.column_name,1,3)||'_LOB
(TABLESPACE TRENT_LOB_01 DISABLE STORAGE IN ROW CHUNK '||a.chunk||' RETENTION INDEX '||substr(a.table_name,1,15)||'_'||substr(a.column_name,1,3)||'_LOBIDX);'
from dba_lobs a, dba_segments b where a.owner = 'TRENTADM'
and a.segment_name = b.segment_name
order by table_name
/
spool off
