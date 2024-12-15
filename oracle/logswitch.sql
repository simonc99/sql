/**********************************************************************
 * File:	logswitch.sql
 * Type:	SQL*Plus script
 * Author:	Tim Gorman (Evergreen Database Technologies, Inc.)
 * Date:	20-Oct-94
 *
 * Description:
 *	PL/SQL procedure to query the V$LOG_HISTORY view and produce
 *	a report depicting the frequency of redo log file switches,
 *	by hour-of-day, by day-of-week, and by day-of-year.
 *
 * Modifications:
 *	TGorman 04Sep98	Updated for Oracle8
 *	TGorman 20Sep99 added output of redo log files sizes
 *********************************************************************/
set serveroutput on size 1000000 feedback off
col instance new_value V_INSTANCE noprint
select  lower(replace(t.instance,chr(0),'')) instance
from    v$thread        t,
        v$parameter     p
where   p.name = 'thread'
and     t.thread# = to_number(decode(p.value,'0','1',p.value));
spool logswitch_&&V_INSTANCE
declare
	--
	cursor get_log_sizes
	is
	select distinct	ltrim(to_char(bytes/1048576,'99,990'))||'M' mb
	from		sys.v_$log;
	--
        cursor get_log_history
        is
        select          to_char(first_time, 'MM/DD/YY HH24:MI:SS') time,
                        to_number(substr(to_char(first_time,'MM/DD/YY HH24:MI:SS'), 1, 2)) month,
                        to_number(substr(to_char(first_time,'MM/DD/YY HH24:MI:SS'), 4, 2)) day,
                        1900 + to_number(substr(to_char(first_time,'MM/DD/YY HH24:MI:SS'), 7, 2)) year,
                        to_number(substr(to_char(first_time,'MM/DD/YY HH24:MI:SS'), 10, 2)) hour,
                        to_number(substr(to_char(first_time,'MM/DD/YY HH24:MI:SS'), 13, 2)) minute,
                        to_number(substr(to_char(first_time,'MM/DD/YY HH24:MI:SS'), 16, 2)) second,
			trunc(first_time - to_date('19700101', 'YYYYMMDD')) days,
			to_number(to_char(first_time,'D')) day_of_wk,
                        (to_number(substr(to_char(first_time,'MM/DD/YY HH24:MI:SS'), 1, 2))*2592000) +
                        (to_number(substr(to_char(first_time,'MM/DD/YY HH24:MI:SS'), 4, 2))*86400) +
                        (to_number(substr(to_char(first_time,'MM/DD/YY HH24:MI:SS'), 10, 2))*3600) +
                        (to_number(substr(to_char(first_time,'MM/DD/YY HH24:MI:SS'), 13, 2))*60) +
                        to_number(substr(to_char(first_time,'MM/DD/YY HH24:MI:SS'), 16, 2)) seconds
        from            sys.v_$log_history
        order by        first_time asc;
        --
        v_earliest_time varchar2(20) := NULL;
        v_prev_seconds  number := 0;
        v_mins          number := 0;
	v_totlessthan30	number := 0;
	v_total		number := 0;
	v_first_day	number := 0;
	v_last_day	number := 0;
	j		binary_integer := 0;
	--
        type num_tab    is table of integer index by binary_integer;
        t_days          num_tab;
        t_days_of_wk    num_tab;
        t_lessthan1     num_tab;
        t_lessthan5     num_tab;
        t_lessthan10    num_tab;
        t_lessthan20    num_tab;
        t_lessthan30    num_tab;
        t_totlessthan30 num_tab;
        t_load          num_tab;
        t_cnt           num_tab;
	v_log_sizes	varchar2(200) := null;
        --
        v_errcontext    varchar2(200);
        v_errmsg        varchar2(200);
        --
begin
--
for i in 0..23 loop
	--
        t_lessthan1(i) := 0;
        t_lessthan5(i) := 0;
        t_lessthan10(i) := 0;
        t_lessthan20(i) := 0;
        t_lessthan30(i) := 0;
        t_totlessthan30(i) := 0;
        t_load(i) := 0;
        t_cnt(i) := 0;
        t_days_of_wk(i) := 0;
	--
end loop;
--
v_errcontext := 'open/fetch get_log_sizes';
for x in get_log_sizes loop
	--
	if get_log_sizes%rowcount = 1 then
		v_log_sizes := x.mb;
	else
		v_log_sizes := ', ' || x.mb;
	end if;
	--
	v_errcontext := 'fetch/close get_log_sizes';
	--
end loop;
--
v_errcontext := 'open/fetch get_log_history';
for x in get_log_history loop
        --
        if get_log_history%rowcount > 1 then
                --
                v_mins := (x.seconds - v_prev_seconds) / 60;
                --
                t_cnt(x.hour) := t_cnt(x.hour) + 1;
                --
                if v_mins <= 1 then
                        t_lessthan1(x.hour) := t_lessthan1(x.hour) + 1;
                elsif v_mins <= 5 then
                        t_lessthan5(x.hour) := t_lessthan5(x.hour) + 1;
                elsif v_mins <= 10 then
                        t_lessthan10(x.hour) := t_lessthan10(x.hour) + 1;
                elsif v_mins <= 20 then
                        t_lessthan20(x.hour) := t_lessthan20(x.hour) + 1;
                elsif v_mins <= 30 then
                        t_lessthan30(x.hour) := t_lessthan30(x.hour) + 1;
                end if;
                --
		t_days_of_wk(x.day_of_wk) := 
			t_days_of_wk(x.day_of_wk) + 1;
                --
		begin
			t_days(x.days - v_first_day) := 
					t_days(x.days - v_first_day) + 1;
		exception when no_data_found then
			t_days(x.days - v_first_day) := 1;
		end;
		v_last_day := x.days;
                --
        else
                --
                v_earliest_time := x.time;
                --
                t_cnt(x.hour) := t_cnt(x.hour) + 1;
                --
		t_days(0) := 1;
		v_first_day := x.days;
		v_last_day := x.days;
                --
        end if;
        --
        v_prev_seconds := x.seconds;
        --
        v_errcontext := 'fetch/close get_log_history';
        --
end loop;
--
for i in 0..23 loop
	--
        t_totlessthan30(i) :=
                t_lessthan1(i) +
                t_lessthan5(i) +
                t_lessthan10(i) +
                t_lessthan20(i) +
                t_lessthan30(i);
        t_load(i) :=
                (t_lessthan1(i) * 10000) +
                (t_lessthan5(i) * 1000) +
                (t_lessthan10(i) * 100) +
                (t_lessthan20(i) * 10) +
                t_lessthan30(i);
        if t_lessthan1(i) = 0 and
           t_lessthan5(i) = 0 and
           t_lessthan10(i) = 0 and
           t_lessthan20(i) = 0 and
           t_lessthan30(i) = 0 then
                t_lessthan1(i) := null;
                t_lessthan5(i) := null;
                t_lessthan10(i) := null;
                t_lessthan20(i) := null;
                t_lessthan30(i) := null;
        elsif t_lessthan1(i) = 0 and
              t_lessthan5(i) = 0 and
              t_lessthan10(i) = 0 and
              t_lessthan20(i) = 0 then
                t_lessthan1(i) := null;
                t_lessthan5(i) := null;
                t_lessthan10(i) := null;
                t_lessthan20(i) := null;
        elsif t_lessthan1(i) = 0 and
              t_lessthan5(i) = 0 and
              t_lessthan10(i) = 0 then
                t_lessthan1(i) := null;
                t_lessthan5(i) := null;
                t_lessthan10(i) := null;
        elsif t_lessthan1(i) = 0 and
              t_lessthan5(i) = 0 then
                t_lessthan1(i) := null;
                t_lessthan5(i) := null;
        elsif t_lessthan1(i) = 0 then
                t_lessthan1(i) := null;
        end if;
	--
end loop;
--
dbms_output.put_line('Log History starts at ' || v_earliest_time);
dbms_output.put_line('Redo log files are sized at: ' || v_log_sizes);
dbms_output.put_line('|');
dbms_output.put_line('|   ====== Total Swtchs ===== Tot  Swt   Redo Load');
dbms_output.put_line('|Hr   <1   <5  <10  <20  <30  <30  Tot      Factor');
dbms_output.put_line('|-- ---- ---- ---- ---- ---- ---- ---- -----------');
for i in 0..23 loop
        --
        dbms_output.put_line('|' || ltrim(to_char(i+1,'00')) ||
             nvl(to_char(t_lessthan1(i),'9990'),'     ') ||
             nvl(to_char(t_lessthan5(i),'9990'),'     ') ||
             nvl(to_char(t_lessthan10(i),'9990'),'     ') ||
             nvl(to_char(t_lessthan20(i),'9990'),'     ') ||
             nvl(to_char(t_lessthan30(i),'9990'),'     ') ||
             to_char(t_totlessthan30(i),'9990') ||
             to_char(t_cnt(i), '9990') ||
             to_char(t_load(i), '999,999,990'));
        --
	v_totlessthan30 := v_totlessthan30 + t_totlessthan30(i);
	v_total := v_total + t_cnt(i);
        --
end loop;
--
dbms_output.put_line('|                            ---- ----');
dbms_output.put_line('|                           ' ||
		to_char(v_totlessthan30, '9990') ||
		to_char(v_total, '9990'));
--
dbms_output.put_line('|');
dbms_output.put_line('|                   Nbr of');
dbms_output.put_line('|Day of Week        Swtchs');
dbms_output.put_line('|-----------        ------');
dbms_output.put_line('|Sunday            ' || to_char(t_days_of_wk(1), '9990'));
dbms_output.put_line('|Monday            ' || to_char(t_days_of_wk(2), '9990'));
dbms_output.put_line('|Tuesday           ' || to_char(t_days_of_wk(3), '9990'));
dbms_output.put_line('|Wednesday         ' || to_char(t_days_of_wk(4), '9990'));
dbms_output.put_line('|Thursday          ' || to_char(t_days_of_wk(5), '9990'));
dbms_output.put_line('|Friday            ' || to_char(t_days_of_wk(6), '9990'));
dbms_output.put_line('|Saturday          ' || to_char(t_days_of_wk(7), '9990'));
--
dbms_output.put_line('|');
dbms_output.put_line('|                  Nbr of');
dbms_output.put_line('|Date              Swtchs');
dbms_output.put_line('|----              ------');
for i in 0..(v_last_day - v_first_day) loop
	--
	begin
		j := t_days(i);
	exception when no_data_found then j := 0;
	end;
	dbms_output.put_line('|' ||
		to_char(to_date('19700101','YYYYMMDD')+v_first_day+i,
				     'Day MON-DD: ') || to_char(j, '9990'));
	--
end loop;
--
exception
        when others then
                v_errmsg := substr(sqlerrm,1,200);
                raise_application_error(-20001, v_errcontext || ': ' ||
                                                v_errmsg);
end;
/
spool off


