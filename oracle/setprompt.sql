undefine usr db
col usr new_value usr
col db  new_value db

set termout off
select lower(user) usr,
       substr(global_name, 1, instr(global_name, '.')-1) db
  from   global_name
/
set termout on

set sqlprompt '&&usr.@&&db.> '
