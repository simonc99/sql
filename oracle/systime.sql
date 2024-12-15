/**********************************************************************
 * File:	systime.sql
 * Type:	SQL*Plus script
 * Author:	Tim Gorman (Evergreen Database Technologies, Inc)
 * Date:	25-Mar-02
 *
 * Description:
 *	SQL*Plus script to display total time spent waiting info
 *	(from V$SYSTEM_EVENT) along with total time spent processing
 *	info (from V$SYSSTAT for "CPU used by this session" statistic),
 *	along with a calculation of the percentage of time the instance
 *	spent doing each thing...
 *
 * Note:
 *	Due to use of "analytic" reporting function, this query can only
 *	be used with v8.1.6 and above...
 *
 * Modifications:
 *********************************************************************/
break on report on username on sid skip 1
set pagesize 100 lines 80 trimspool on trimout on verify off

undef usr

col type format a5 heading "Svc,|Idle,|Wait"
col name format a35 heading "Name" truncate
col tot_secs_spent format 999,999,999,990.00 heading "Total|Seconds|Spent"
col pct_total format 990.00 heading "%|Total"
col nonidle_total format 990.00 heading "%|NonIdle"

select	type,
	name,
	tot_secs_spent,
	(tot_secs_spent / (sum(tot_secs_spent) over ()))*100 pct_total,
	(nonidle_secs_spent / (sum(nonidle_secs_spent) over ()))*100 nonidle_total
from	(select	decode(event,
			'rdbms ipc message', 'Idle',
			'rdbms ipc reply', 'Idle',
			'SQL*Net message from client', 'Idle',
			'SQL*Net break/reset to client', 'Idle',
			'pipe get', 'Idle',
			'pmon timer', 'Idle',
			'smon timer', 'Idle',
			'dispatcher timer', 'Idle',
			'virtual circuit status', 'Idle',
			'PX Idle Wait', 'Idle',
			'PX Deq: Execute Reply', 'Idle',
			'PX Deq: Execution Msg', 'Idle',
			'PX Deq: Table Q Normal', 'Idle',
			'PX Deq Credit: send blkd', 'Idle',
			'PX Deq Credit: need buffer', 'Idle',
			'PX Deq: Parse Reply', 'Idle',
			'PX Deq: Signal ACK', 'Idle',
			'PX Deq: Join ACK', 'Idle',
			'PX qref latch', 'Idle',
			'PX Deq: Msg Fragment', 'Idle',
			'PL/SQL lock timer', 'Idle',
			'inactive session', 'Idle',
				'Wait') type,
		event name,
		time_waited/100 tot_secs_spent,
		decode(event,
			'rdbms ipc message', 0,
			'rdbms ipc reply', 0,
			'SQL*Net message from client', 0,
			'SQL*Net break/reset to client', 0,
			'pipe get', 0,
			'pmon timer', 0,
			'smon timer', 0,
			'dispatcher timer', 0,
			'virtual circuit status', 0,
			'PX Idle Wait', 0,
			'PX Deq: Execute Reply', 0,
			'PX Deq: Execution Msg', 0,
			'PX Deq: Table Q Normal', 0,
			'PX Deq Credit: send blkd', 0,
			'PX Deq Credit: need buffer', 0,
			'PX Deq: Parse Reply', 0,
			'PX Deq: Signal ACK', 0,
			'PX Deq: Join ACK', 0,
			'PX qref latch', 0,
			'PX Deq: Msg Fragment', 0,
			'PL/SQL lock timer', 0,
			'inactive session', 0,
				time_waited/100) nonidle_secs_spent
	 from	v$system_event
	 where	time_waited > 0
	 union all
	 select	'Svc' type,
		'other cpu usage' name,
		(t.value - (p.value + r.value))/100 tot_secs_spent,
		(t.value - (p.value + r.value))/100 nonidle_secs_spent
	 from	v$sysstat t,
		v$sysstat p,
		v$sysstat r
	 where	t.name = 'CPU used by this session'
	 and	p.name = 'recursive cpu usage'
	 and	r.name = 'parse time cpu'
	 union all
	 select	'Svc' type,
		name,
		value/100 tot_secs_spent,
		value/100 nonidle_secs_spent
	 from	v$sysstat
	 where	name = 'recursive cpu usage'
	 and	value > 0
	 union all
	 select	'Svc' type,
		name,
		value/100 tot_secs_spent,
		value/100 nonidle_secs_spent
	 from	v$sysstat
	 where	name = 'parse time cpu'
	 and	value > 0)
order by 5 desc, 4 desc, 3 desc, 2;
