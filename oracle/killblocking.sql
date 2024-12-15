set heading off feedback off
select 'ALTER SYSTEM KILL SESSION '''||a.holding_session||','||b.serial#||''';' from dba_blockers a, v$session b where a.holding_session = b.sid
order by last_call_et;
set heading on feedback 3
