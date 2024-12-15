set lines 300 trimspool on trimout on pages 0 heading off feedback off 
select 'exec dbms_system.set_ev('||sid||','||serial#||',10046,0,'''');' from v$session where username = 'TRENTADM' and status = 'ACTIVE';
