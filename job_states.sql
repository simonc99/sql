set lines 400 trimspool on trimout on pages 400
col last_start_date for a25
col last_end_date for a25
col next_run_date for a25
select job_name, to_char(last_start_date,'HH24:MI:SS DD-MON-YYYY') last_start_date, 
to_char(last_start_date+LAST_RUN_DURATION,'HH24:MI:SS DD-MON-YYYY') last_end_date, 
to_char(next_run_date,'HH24:MI:SS DD-MON-YYYY') next_run_date, state
from dba_scheduler_jobs where owner in ('USD','QUERCUS','CITSYS')
order by owner
/
