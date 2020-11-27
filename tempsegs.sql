break on report
compute sum of MB extents blocks on report
set linesize 140
column username for a15
column tablespace for a10
column MB for 999,999.99
column extents for 999,999
column initial_extent for 999,999,999
column next_extent for 999,999,999
column blocks for 999,999,999
 
select vtu.username, vtu.tablespace, (vtu.extents*dts.next_extent/1024/1024) as MB, 
vtu.extents, dts.initial_extent, dts.next_extent, vtu.blocks 
from v$tempseg_usage vtu, dba_tablespaces dts 
where dts.tablespace_name = 'TEMP' 
order by vtu.username;
/
