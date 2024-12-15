set lines 300 trimspool on trimout on pages 0 heading off feedback off 
select 'exec dbms_system.set_ev('||sid||','||serial#||',10046,12,''''); -- '||program from v$session where osuser = 'SavigarH' order by last_call_et;
set echo on feedback on 
