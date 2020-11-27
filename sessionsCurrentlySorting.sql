
prompt
prompt Sessions Currently Sorting
prompt ==========================
prompt (Temporary Tablespace Set to TEMP)

select	sid
from 	v$session_wait sw,
	dba_data_files df
where 	sw.p1 = df.file_id
and	df.tablespace_name = 'TEMP'
and 	sw.event = 'db file scattered read';

