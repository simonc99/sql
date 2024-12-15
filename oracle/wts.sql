/********************************************************************
 * File:        wts.sql
 * Type:        SQL*Plus script
 * Author:      Tim Gorman (Evergreen Database Technologies, Inc.)
 * Date:        01-Dec-99
 *
 * Description:
 *      Script to display more session-level and SQL-level information
 *	about sessions waiting on a "buffer busy waits", "write complete
 *	waits", and "free buffer waits".
 *
 * Modification:
 *
 ********************************************************************/
set pages 100 lines 500 trimspool on trimout on space 1 recsep each

col sid format 990
col program format a15 word_wrap
col event format a8 word_wrap
col ospid format 9999990 heading "Srvr|PID"
col name format a15 word_wrap heading "OBJECT NAME"
col sql_text format a25 word_wrap
select /*+ rule */
	w.sid,
	w.event,
	s.program,
	p.spid ospid,
	e.owner || '.' || e.segment_name || ' (' || e.segment_type || ')' name,
	a.sql_text
from	sys.v_$sqlarea		a,
	sys.dba_extents		e,
	sys.v_$process		p,
	sys.v_$session		s,
	sys.v_$session_wait	w
where	w.event in ('write complete waits',
		    'buffer busy waits',
		    'free buffer waits')
and	s.sid = w.sid
and	p.addr = s.paddr
and	e.file_id = to_number(w.p1)
and	to_number(w.p2) between e.block_id and (e.block_id + (e.blocks - 1))
and	a.address (+) = s.sql_address;
