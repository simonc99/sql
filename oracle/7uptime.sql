select round(avg(sysdate - logon_time)) "Uptime (days)" from v$session where username is null;
