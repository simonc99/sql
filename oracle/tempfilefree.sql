set lines 132
col name for a60
select a.name, (b.bytes_free+b.bytes_used)/1024/1024/1024 "GB TOTAL",
b.bytes_used/1024/1024/1024 "GB USED",
b.bytes_free/1024/1024/1024 "GB FREE"
from v$tempfile a, v$temp_space_header b where
a.file# = b.file_id
order by a.file#
/

