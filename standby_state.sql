set lines 100
col dest_name for a20
select recovery_mode, type, dest_name, archived_seq#, applied_seq#
from V$ARCHIVE_DEST_STATUS
where status = 'VALID'
/
