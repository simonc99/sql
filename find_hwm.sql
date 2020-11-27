set serveroutput on size 1000000

declare

t_total_blocks  number ;
t_total_bytes  number ;
t_unused_blocks  number ;
t_unused_bytes  number ;
t_last_used_extent_file_id  number ;
t_last_used_extent_block_id  number ;
t_last_used_block  number ;
t_owner dba_segments.owner%type := 'TRENTADM';
t_object_name dba_segments.segment_name%type := 'UCFIELD';
t_object_type dba_segments.segment_type%type := 'TABLE';
t_tablespace_name dba_segments.tablespace_name%type := NULL ;
t_partition_name dba_segments.partition_name%type := NULL    ;

cursor c_dba_segments is
select * from dba_segments s
where s.owner        = t_owner
and   s.segment_type = t_object_type
and   s.segment_name = t_object_name
and   (  s.partition_name is NULL
       or  s.partition_name = t_partition_name ) ;

cursor c_dba_free_space is
select sum(dfs.bytes) as total_bytes
from   dba_free_space dfs
where  dfs.tablespace_name = t_tablespace_name ;


begin
DBMS_SPACE.UNUSED_SPACE(
t_owner,
t_object_name,
t_object_type,
t_total_blocks,
t_total_bytes,
t_unused_blocks,
t_unused_bytes,
t_last_used_extent_file_id,
t_last_used_extent_block_id,
t_last_used_block,
t_partition_name ) ;

dbms_output.put_line('Allocated '||t_total_bytes/1024/1024||'MB Free '||t_unused_bytes/1024/1024||'MB Needed '||(t_total_bytes-t_unused_bytes)/1024/1024||'MB');

for A1 in c_dba_segments
loop
    dbms_output.put_line(t_owner||'.'||t_object_name||' allocated '||to_char(A1.bytes/1024/1024)||'MB');
    t_tablespace_name := A1.tablespace_name;
    for A2 in c_dba_free_space
    loop
        dbms_output.put_line('Tablespace '||A1.tablespace_name||' free space '||to_char(A2.total_bytes/1024/1024)||'MB');
    end loop ;
end loop ;
end ;

