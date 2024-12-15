set lines 4000 trimspool on 
break on tablespace_name
select a.tablespace_name "Tablespace Name", b.status "Backup Mode?" from dba_data_files a,
v$backup b where a.file_id = b.file#
order by tablespace_name
/
