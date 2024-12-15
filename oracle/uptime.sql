select
  trunc(sysdate - startup_time)  days,
  trunc(mod(24 * (sysdate - startup_time), 24))  hours,
  round(mod(60 * 24 * (sysdate - startup_time), 60))  minutes
from
  sys.v_$instance
/

