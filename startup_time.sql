column startup format a15
column time format a20
select distinct Startup, Time from v$instance,
(select to_date(value,'J') Startup
from v$instance where key = 'STARTUP TIME - JULIAN'),
(select to_char(to_date(value,'SSSSS'),'hh24:mi:ss') Time from v$instance where
key = 'STARTUP TIME - SECONDS')
/
