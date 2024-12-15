set pagesize 5000
col event 	format	a25 		heading 'Wait Event' trunc;
col tws 	format 	9999999999	heading 'Total|Waits';
col tt 		format 	9999999999	heading 'Total|Timeouts';
col tw 		format 	99999999.9	heading 'Time (sec)|Waited';
col avgw 	format 	9999999		heading 'Avg (ms)|Wait';

select 	event,
	total_waits tws,
	total_timeouts tt,
	time_waited /1000 tw,
	average_wait avgw
from  v$system_event
order by time_waited desc;

