/* Compile invalid objects */
-- Obsolete!! Run $ORACLE_HOME/rdbms/admin/utlrp.sql

rem set term off
set heading off
set pagesize 4000
set feedback off
set linesize 4000
set trimspool on
set echo off

-- spool gl_compile_out.sql

select 'set echo on' from dual;
select 'set feedback on' from dual;
select 'spool compile' from dual;

select 'alter '||decode(object_type,'PACKAGE BODY','PACKAGE','VIEW','VIEW','FUNCTION','FUNCTION','TRIGGER','TRIGGER','PROCEDURE')||' '||owner||'.'||object_name||' compile;'||chr(10)||'show errors'
from dba_objects
where status != 'VALID'
and object_type = 'VIEW'
;
select 'alter '||decode(object_type,'PACKAGE BODY','PACKAGE','VIEW','VIEW','FUNCTION','FUNCTION','TRIGGER','TRIGGER','PROCEDURE')||' '||owner||'.'||object_name||' compile;'||chr(10)||'show errors'
from dba_objects
where status != 'VALID'
and object_type = 'FUNCTION'
;
select 'alter '||decode(object_type,'PACKAGE','PACKAGE','PACKAGE BODY','PACKAGE','VIEW','VIEW','FUNCTION','FUNCTION','TRIGGER','TRIGGER','PROCEDURE')||' '||owner||'.'||object_name||' compile;'||chr(10)||'show errors'
from dba_objects
where status != 'VALID'
and object_type IN ( 'PROCEDURE', 'PACKAGE')
;
select 'alter '||decode(object_type,'PACKAGE BODY','PACKAGE','VIEW','VIEW','FUNCTION','FUNCTION','TRIGGER','TRIGGER','PROCEDURE')||' '||owner||'.'||object_name||' compile;'||chr(10)||'show errors'
from dba_objects
where status != 'VALID'
and object_type = 'TRIGGER'
;
SELECT 'Alter Package '||
	 x.owner || '.' ||
	 x.object_name||
         ' compile ' ||
         Decode( x.object_type
          , 'PACKAGE', 'PACKAGE'
	  , 'BODY' ) ||
	   ' ;'||chr(10)||'show errors'
	   FROM   dba_objects x
           WHERE  x.status   != 'VALID'
	   AND    x.object_type = 'PACKAGE BODY'
   AND not exists ( select y.object_name
    from dba_objects y
     where x.owner = y.owner
      and x.object_name = y.object_name
      and y.status != 'VALID' 
       and y.object_type = 'PACKAGE')
  ;

-- spool off

rem set term on
set heading on
set feedback on

-- @gl_compile_out

rem Exit
