select machine, count(*) from v$session where
username = 'TRENTADM' group by machine;
