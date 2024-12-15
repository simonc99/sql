define m_tablespace = 'TRENT_DATA_01'

select
	file_id,
	block_id,
	block_id + blocks - 1	end_block,
	owner,
	segment_name,
	partition_name,
	segment_type
from
	dba_extents
where
	tablespace_name = '&m_tablespace'
union all
select
	file_id,
	block_id,
	block_id + blocks - 1	end_block,
	'free'			owner,
	'free'			segment_name,
	null			partition_name,
	null			segment_type
from
	dba_free_space
where
	tablespace_name = '&m_tablespace'
order by
	1,2
/
