column "Login time" format a20
set pagesize 4000
column "User" format a20
select username "User", to_char(logon_time, 'HH24:MI:SS DD/MON/YYYY') "Login time" from v$session where username not in ('SYS','SYSTEM') and username is not null order by username, logon_time;
select username "User", count(*) "Logins" from v$session where username not in ('SYS','SYSTEM') and username is not null group by username;
