REM ******************MATRIX******************MATRIX******************MATRIX
REM
REM Developed by:  MATRIX Information Technologies
REM
REM Email:
REM             matrix@compusmart.ab.ca
REM
REM Home Page:
REM             http://www.compusmart.ab.ca/matrix
REM
REM Script: 
REM             tbconst.sql
REM

REM
REM             NOTE * Need select access against sys.dba_cons_columns and 
REM                    sys.dba_constraints to run this.
REM
REM Parameter:
REM             owner = owner of the table
REM             table = name of table to report on
REM
REM Usage: 
REM             SQL> @tbconst.sql  REM
REM Oracle Version:
REM             Tested on Version 7.1.4 as a dba user
REM             Tested on Version 7.2.3 as user sys
REM
REM History:
REM
REM DATE(DMY)   AUTHOR              DESCRIPTION
REM ----------  -----------------   ----------------------------------------
REM 27/11/96    TREVOR MCCLOY       Created
REM
REM ******************MATRIX******************MATRIX******************MATRIX
REM ******************MATRIX******************MATRIX******************MATRIX
REM Capture owner and table name parameters
REM ******************MATRIX******************MATRIX******************MATRIX
def owner = &&1
def table_name = &&2
REM ******************MATRIX******************MATRIX******************MATRIX
REM Define working variables
REM ******************MATRIX******************MATRIX******************MATRIX
def gScript  = 'tbconst.sql'
def gTitle = 'Constraints against table &owner..&table_name'
 
REM ******************MATRIX******************MATRIX******************MATRIX
REM Set the system variables
REM ******************MATRIX******************MATRIX******************MATRIX
set concat on
set echo off
set embedded off
set pagesize 58
set showmode off
set space 1
set termout on
set trimout on
set verify off
set wrap on
REM ******************MATRIX******************MATRIX******************MATRIX
REM Get today's date
REM ******************MATRIX******************MATRIX******************MATRIX
set termout off
 
col today new_value now noprint
 
select  to_char(sysdate, 'DD Mon YYYY HH:MIam') today
from    dual;
REM ******************MATRIX******************MATRIX******************MATRIX
REM Get the name of the database
REM ******************MATRIX******************MATRIX******************MATRIX
 
col dbname new_value sid noprint
 
select  name dbname
from    v$database;
 
REM ******************MATRIX******************MATRIX******************MATRIX
REM Set the report title based on the information gathered and passed
REM ******************MATRIX******************MATRIX******************MATRIX
 
clear breaks
set termout on
set heading on
 
ttitle -
    left 'Database: &sid'       right now               skip 0 -
    left '  Report: &gScript' right 'Page ' sql.pno     skip 2 -
    center '&gTitle'                                    skip 2
 
set newpage 0
 
REM ******************MATRIX******************MATRIX******************MATRIX
REM Run the Report
REM ******************MATRIX******************MATRIX******************MATRIX
set linesize 80
set arraysize 1
create or replace package mitconstraint as
        function        mit$getcols (   cn_name in varchar2, 
                                        cn_owner in varchar2,
                                        tb_name in varchar2)
                        return varchar2;
        pragma          restrict_references (mit$getcols, WNDS,WNPS);
        function        mit$getdesc (   cn_name in varchar2, 
                                        cn_owner in varchar2,
                                        tb_name in varchar2)
                        return varchar2;
        pragma          restrict_references (mit$getdesc, WNDS,WNPS);
end mitconstraint;
/
 
create or replace package body mitconstraint as
function mit$getcols (
                        cn_name in varchar2, 
                        cn_owner in varchar2,
                        tb_name in varchar2)
return varchar2
as
        val varchar2(500);
        col_name varchar2(30);
        found boolean;
 
        cursor c1 is
                select  column_name
                from    sys.dba_cons_columns
                where   constraint_name = upper(cn_name) and
                        owner = upper(cn_owner) and
                        table_name = upper(tb_name);
 
Begin
        val := '';
        found := FALSE;
        for record in c1 Loop
                if found = FALSE then
                        found := TRUE;
                else
                        val := val ||', ';
                end if;
                val := val || record.column_name;
        end loop;
        return val;
end mit$getcols;
function mit$getdesc (
                        cn_name in varchar2,
                        cn_owner in varchar2,
                        tb_name in varchar2)
return varchar2
as
        cn_type char(1);
        descr varchar2(2000);
        found boolean;
        cursor c1 is
                select  owner || '.' || table_name val
                from    sys.dba_constraints
                where   r_owner = upper(cn_owner) and
                        r_constraint_name = upper(cn_name);
begin
        found := FALSE;
        descr := '';
        select  constraint_type
        into    cn_type
        from    sys.dba_constraints
        where   constraint_name = upper(cn_name) and
                owner = upper(cn_owner) and
                table_name = upper(tb_name);
        if cn_type = 'U' then
                descr := ' ';
        else    if cn_type = 'P' then
                        descr := 'Referenced by: ';
                for record in c1 loop
                        if found = FALSE then
                                found := TRUE;
                        else
                                descr := descr || ', ';
                        end if;
                        descr := descr || record.val;
                end loop;
        else    if cn_type = 'R' then
                        select  'References ' || b.owner || '.' || b.table_name
                        into    descr
                        from    dba_constraints a, 
                                dba_constraints b
                        where   a.table_name = upper(tb_name) and
                                a.owner = upper(cn_owner) and
                                a.constraint_name = upper(cn_name) and
                                b.owner = a.r_owner and
                                b.constraint_name = a.r_constraint_name;
        else    if cn_type = 'C' then
                        select  search_condition
                        into    descr
                        from    dba_constraints
                        where 
                                constraint_name = upper(cn_name) and
                                owner = upper(cn_owner) and
                                table_name = upper(tb_name);
                        descr := ltrim(descr);
                else
                        descr := ' ';
                end if;
        end if;
        end if;
        end if;
        return descr;
 
end mit$getdesc;
end mitconstraint;
/
rem
col constraint_name     format a12      heading 'Constraint|Name'
col type                format a11      heading 'Type'
col cols                format a21      heading 'Columns'
col des                 format a33      heading 'Description'
select  constraint_name, 
        'Primary Key' type, 
        mitconstraint.mit$getcols(constraint_name,'&owner','&table_name') cols,
        mitconstraint.mit$getdesc(constraint_name,'&owner','&table_name') des
from    dba_constraints
where   owner=upper('&owner') and
        table_name = upper('&table_name') and
        constraint_type = 'P'
union
select  constraint_name, 
        'Referential' type,
        mitconstraint.mit$getcols(constraint_name,'&owner','&table_name') cols,
        mitconstraint.mit$getdesc(constraint_name,'&owner','&table_name') des
from    dba_constraints
where   owner=upper('&owner') and
        table_name =upper('&table_name') and
        constraint_type = 'R'
union
select  constraint_name, 
        'Table Check' type,
        mitconstraint.mit$getcols(constraint_name,'&owner','&table_name') cols,
        mitconstraint.mit$getdesc(constraint_name,'&owner','&table_name') des
from    dba_constraints
where   owner=upper('&owner') and
        table_name = upper('&table_name') and
        constraint_type = 'C'
union
select  constraint_name, 
        'View Check' type,
        mitconstraint.mit$getcols(constraint_name,'&owner','&table_name') cols,
        mitconstraint.mit$getdesc(constraint_name,'&owner','&table_name') des
from    dba_constraints
where   owner=upper('&owner') and
        table_name = upper('&table_name') and
        constraint_type = 'V'
union
select  constraint_name, 
        'Unique' type,
        mitconstraint.mit$getcols(constraint_name,'&owner','&table_name') cols,
        mitconstraint.mit$getdesc(constraint_name,'&owner','&table_name') des
from    dba_constraints
where   owner=upper('&owner') and
        table_name = upper('&table_name') and
        constraint_type = 'U'
order by 2,1
/
drop package mitconstraint;
REM ******************MATRIX******************MATRIX******************MATRIX
REM Clear variables
REM ******************MATRIX******************MATRIX******************MATRIX
undefine owner
undefine table_name
undefine gScript
undefine gTitle
ttitle off
btitle off
clear column
clear breaks
 
REM ******************MATRIX******************MATRIX******************MATRIX
REM End of Script
REM ******************MATRIX******************MATRIX******************MATRIX
