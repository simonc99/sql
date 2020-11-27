col snap_id new_value v_snap_id

select max(snap_id) as snap_id from dba_hist_snapshot;

select
  s.elapsed_time_delta,
  s.buffer_gets_delta,
  s.disk_reads_delta,
  cursor(select * from table(dbms_xplan.display_awr(t.sql_id, s.plan_hash_value)))
from
  dba_hist_sqltext t,
  dba_hist_sqlstat s
where
  t.dbid = s.dbid
  and t.sql_id = s.sql_id
--  and s.snap_id between &v_snap_id-2 and &v_snap_id
  and upper(t.sql_text) like '%CLEARING_HOUSE_COURS%'
;

