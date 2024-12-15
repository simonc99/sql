set echo off termout off
set pause off pagesize 63 linesize 80 tab off trimout on trimspool on
set pause "RETURN for data"
alter session set nls_date_format='HH24:MI:SS DD-MON-YYYY';
set termout on heading off
-- select 'Logged in to : '||global_name from global_name;
set echo off heading on feedback 2
set sqlprompt "_USER'@'_CONNECT_IDENTIFIER SQL> "
