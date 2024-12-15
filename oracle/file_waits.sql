rem
rem	Script:		file_wait.sql
rem	Author:		J.P.Lewis
rem	Dated:		7-Jan-1997
rem	Purpose:	List buffer busy waits by files
rem

clear columns
clear breaks
column	file#		format 999	Heading "File"
column	ct		format 999999	heading "Waits"
column	time		format 999999	heading "Time"
column	avg		format 999.999	heading	"Avg time"
select 
	indx+1		file#,
	count		ct,
	time,
	time/(decode(count,0,1,count))	avg
from x$kcbfwait
where
	indx < (select count(*) from v$datafile)
;

