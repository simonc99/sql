-- if ROW_WAIT_ROW# is 0, then it's an index

set linesize 300

column object_name for a32
col username for a12 
col osuser for a12

select 
	s.username, s.osuser, s.sid, s.serial#,
	do.object_name,
	row_wait_obj#, 
	row_wait_file#, 
	row_wait_block#, 
	row_wait_row#,
	dbms_rowid.rowid_create (1,ROW_WAIT_OBJ#,ROW_WAIT_FILE#,ROW_WAIT_BLOCK#,ROW_WAIT_ROW#)
from 
	v$session s, dba_objects do
where 
	sid in (select distinct session_id 
		from v$locked_object)
and 
	s.ROW_WAIT_OBJ# = do.OBJECT_ID 
/
