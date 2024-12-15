col hash_value form 99999999999999999
select 	hash_value, 
	executions,
	buffer_gets,
	disk_reads,
	sorts
from v$sqlarea
where sorts > 1
order by sorts desc;
