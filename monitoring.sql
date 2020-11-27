set pagesize 1000;
set linesize 80;
set heading off;
set feedback off;
set echo off;

col clss form 999 just l
col ttl form a25
col val form 999,999,999.9999

prompt Class	Description
prompt 	1	hit ratio
prompt 	2	summed dirty queue length/write requests
prompt 	3	percentage of latch contention from key latches (misses/gets)
prompt 	4	sysstat figures
prompt 	5	rollstat figures

select	1 as clss,
	 'Hit_Ratio' as ttl,
	(sum(decode(name, 'consistent gets',value, 0))  +
	 sum(decode(name, 'db block gets',value, 0))  -
	 sum(decode(name, 'physical reads',value, 0)))
       /
	(sum(decode(name, 'consistent gets',value, 0))  +
	 sum(decode(name, 'db block gets',value, 0))  )  * 100 as val
from v$sysstat st
union
select	2 as clss,
	'Write_Request_Length' as ttl,
	sum( decode (name, 'summed dirty queue length', value))
	/
	sum( decode (name, 'write requests', value)) as val
from v$sysstat
where  name in ( 'summed dirty queue length', 'write requests')
and  value > 0
union
select	3 as clss,
	'cache_buffers_lru_chain' as ttl,
	(sum(decode(ln.name, 'cache buffers lru chain', misses,0))
	/
	 greatest(sum(decode(ln.name, 'cache buffers lru chain', gets,0)),1)) * 100 val
from	v$latch l, 
	v$latchname ln
where	l.latch# = ln.latch#
union
select	3 as clss,
	'cache_buffers_lru_chain' as ttl,
	(sum(decode(ln.name, 'cache buffers lru chain', misses,0))
	/
	 greatest(sum(decode(ln.name, 'cache buffers lru chain', gets,0)),1)) * 100 val
from	v$latch l, 
	v$latchname ln
where	l.latch# = ln.latch#
union
select	3 as clss,
	'enqueues' as ttl,
	(sum(decode(ln.name, 'enqueues', misses,0))
	/
	greatest(sum(decode(ln.name, 'enqueues', gets,0)),1)) * 100 val
from	v$latch l, 
	v$latchname ln
where	l.latch# = ln.latch#
union
select	3 as clss,
	'redo allocation' as ttl,
     	(sum(decode(ln.name, 'redo allocation', misses,0))
     	/ 
	greatest(sum(decode(ln.name, 'redo allocation', gets,0)),1)) * 100 val
from	v$latch l, 
	v$latchname ln
where	l.latch# = ln.latch#
union
select	3 as clss,
	'redo copy' as ttl,
	(sum(decode(ln.name, 'redo copy', misses,0))
     	/
	greatest(sum(decode(ln.name, 'redo copy', gets,0)),1)) * 100 val
from	v$latch l, 
	v$latchname ln
where	l.latch# = ln.latch#
union
select 	4 as clss,
	'redo log space wait time' as ttl,
	value as val
from 	v$sysstat 
where 	name = 'redo log space wait time'
union
select 	4 as clss,
	'redo log space requests' as ttl,
	value as val
from 	v$sysstat 
where 	name = 'redo log space requests'
union
select	5 as clss,
	'sum_hwmsize(Mb)' as ttl,
	SUM(RS.hwmsize)/(1024*1024) as val
from 	V$ROLLSTAT RS
union
select	5 as clss,
	'sum_extends' as ttl,
	SUM(rs.wraps) as val
from 	V$ROLLSTAT RS
union
select	5 as clss,
	'sum_wraps' as ttl,
	SUM(rs.wraps) as val
from 	V$ROLLSTAT RS
union
select	5 as clss,
	'sum_shrinks' as ttl,
	SUM(RS.shrinks) as val
from 	V$ROLLSTAT RS




/


