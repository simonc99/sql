set lines 160 pages 4000 trimspool on trimout on 
SELECT tf.* FROM DBA_HIST_SQLTEXT ht, table
(DBMS_XPLAN.DISPLAY_AWR(ht.sql_id,null, null, 'ALL' )) tf
WHERE ht.sql_text like '%OBJECT_VALIDATION%'
-- WHERE ht.sql_id='4czayazd6pqmm'
/
