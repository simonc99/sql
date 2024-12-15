col FILENAME for a51
select substr(file_name,1,50) FILENAME, 
ceil( (nvl(hwm,1)*8192)/1024/1024 ) smallest, 
ceil( blocks*8192/1024/1024) currsize, 
ceil( blocks*8192/1024/1024) -ceil( 
(nvl(hwm,1)*8192)/1024/1024 ) savings 
from dba_data_files a, 
( select file_id, max(block_id+blocks-1) hwm 
from dba_extents 
group by file_id ) b 
where a.file_id = b.file_id(+)
