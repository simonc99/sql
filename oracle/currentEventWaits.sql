
set pagesize 5000
prompt
prompt Session wait summary


col event form a30
select 	event, 
	sum(decode (wait_time, 0, 0, 1)) "Previous Waits",
	sum(decode(wait_time,0,1,0)) "Currently Waiting",
	count(*) "Total Waits"
from 	v$session_wait
group by event
order by 4;
