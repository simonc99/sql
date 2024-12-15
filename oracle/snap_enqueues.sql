rem
rem	Script:		snap_enqueue.sql
rem	Author:		Jonathan Lewis
rem	Dated:		March 2001
rem	Purpose:	Package to get snapshot start and delta of v$enqueue_stat
rem
rem	Notes
rem		Version 9 specific code, but I have included an 
rem		alternative cursor that can be used for Oracle 8
rem
rem		The script has to be run by SYS to create the package
rem
rem	Usage:
rem		set serveroutput on size 1000000 format wrapped
rem		set linesize 120
rem		set trimspool on
rem		execute snap_enqueues.start_snap
rem		-- do something
rem		execute snap_enqueues.end_snap
rem

create or replace package snap_enqueues as
	procedure start_snap;
	procedure end_snap;
end;
/

create or replace package body snap_enqueues as

/*
	Quick retro-fix for Oracle 8  - but there are more columns available 
	In particular, version 9 has a wait time in MILLI seconds

	cursor c1 is
		select 
			indx,
			ksqsttyp	eq_type, 
			ksqstget	requests, 
			ksqstwat	waits,
			ksqstget	success,
			0		failed,
			0		wait_ms
		from 
			x$ksqst 
		where ksqstget != 0
	;

*/

	cursor c1 is
		select 
			indx,
			ksqsttyp 	eq_type, 
			ksqstreq 	requests, 
			ksqstwat 	waits,
			ksqstsgt	success,
			ksqstfgt	failed,
			ksqstwtm	wait_ms
		from 
			x$ksqst 
		where ksqstreq != 0
	;

	type w_type is table of c1%rowtype index by binary_integer;
	w_list w_type;
	w_empty_list	w_type;

	m_start_time	date;
	m_start_flag	char(1);
	m_end_time	date;

procedure start_snap is
begin

	m_start_time := sysdate;
	m_start_flag := 'U';
	w_list := w_empty_list;

	for r in c1 loop
		w_list(r.indx).eq_type := r.eq_type;
		w_list(r.indx).requests := r.requests;
		w_list(r.indx).waits := r.waits;
		w_list(r.indx).success := r.success;
		w_list(r.indx).failed := r.failed;
		w_list(r.indx).wait_ms := r.wait_ms;
	end loop;

end start_snap;


procedure end_snap is
begin

	m_end_time := sysdate;

	dbms_output.put_line('----------------------------------');
	dbms_output.put_line('System enqueues - ' || 
				to_char(sysdate,'dd-Mon hh24:mi:ss') 
	);

	if m_start_flag = 'U' then
		dbms_output.put_line('Interval:-      '  || 
				trunc(86400 * (m_end_time - m_start_time)) ||
				' seconds'
		);
	else
		dbms_output.put_line('Since Startup:- ' || 
				to_char(m_start_time,'dd-Mon hh24:mi:ss')
		);
	end if;

	dbms_output.put_line('----------------------------------');

	dbms_output.put_line(
		rpad('Type',4) ||
		lpad('Requests',12) ||
		lpad('Waits',12) ||
		lpad('Success',12) ||
		lpad('Failed',12) ||
		lpad('Wait m/s',12)
	);

	dbms_output.put_line(
		rpad('----',4) ||
		lpad('--------',12) ||
		lpad('-----',12)||
		lpad('-------',12) ||
		lpad('------',12) ||
		lpad('--------',12)
	);

	for r in c1 loop
		if (not w_list.exists(r.indx)) then
		    w_list(r.indx).requests := 0;
		    w_list(r.indx).waits := 0;
		    w_list(r.indx).success := 0;
		    w_list(r.indx).failed := 0;
		    w_list(r.indx).wait_ms := 0;
		end if;

		if (
			   (w_list(r.indx).requests != r.requests)
			or (w_list(r.indx).waits != r.waits)
			or (w_list(r.indx).success != r.success)
			or (w_list(r.indx).failed != r.failed)
			or (w_list(r.indx).wait_ms != r.wait_ms)
		) then
			dbms_output.put(rpad(r.eq_type,4));
			dbms_output.put(to_char( 
				r.requests - w_list(r.indx).requests,
					'999,999,990')
			);
			dbms_output.put(to_char( 
				r.waits - w_list(r.indx).waits,
					'999,999,990'));
			dbms_output.put(to_char( 
				r.success - w_list(r.indx).success,
					'999,999,990'));
			dbms_output.put(to_char( 
				r.failed - w_list(r.indx).failed,
					'999,999,990'));
			dbms_output.put(to_char( 
				r.wait_ms - w_list(r.indx).wait_ms,
					'999,999,990'));
			dbms_output.new_line;
		end if;
	end loop;

end end_snap;

--
--	Instantiation code - get system startup time
--	just in case user wants stats since startup
--

begin
	select
		startup_time, 'S'
	into
		m_start_time, m_start_flag
	from
		v$instance;

end snap_enqueues;
/


