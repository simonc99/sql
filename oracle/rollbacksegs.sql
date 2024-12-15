prompt If OPTIMAL parameter of rolback segments is incorrect, unnecessary shrinks and growth will occur
prompt hwmsize = High Water Mark

select RN.name, RS.hwmsize, rs.optsize, rs.wraps, RS.extents, RS.shrinks, RS.aveshrink, RS.aveactive
from V$ROLLNAME RN, V$ROLLSTAT RS where RN.usn = RS.usn;


prompt If there are too few rollback segments, waits may occur.
prompt If rollback segments are small, they can be cached in memory.

select usn, gets, waits, writes, rssize, xacts, shrinks, wraps from V$ROLLSTAT;

select 'Rollback Segments are not using dedicated tablespaces. This often hinders performance.'
  from dual
where 0 < 
(select count(*) from dba_tablespaces
  where tablespace_name in
   (select tablespace_name from dba_segments 
     where segment_type like 'RO%'
       and tablespace_name != 'SYSTEM'
    INTERSECT
    select tablespace_name from dba_segments 
     where segment_type not like 'RO%'))
/

select  segment_name, tablespace_name 
  from  dba_rollback_segs
where   0 < 
(select count(*) from dba_tablespaces
  where tablespace_name in
   (select tablespace_name from dba_segments 
     where segment_type like 'RO%'
       and tablespace_name != 'SYSTEM'
    INTERSECT
    select tablespace_name from dba_segments 
     where segment_type not like 'RO%'))
/

set heading off
select 'You have had a number of rollback segment waits. Try adding '|| sum(decode(waits,0,0,1)) nl,
       'rollback segments to avoid rollback header contention. '
 from v$rollstat
/
set heading on
prompt 'Rollback Segment Activity Since the Instance Started'  

select usn "Rollback Table", Gets, Waits , xacts "Active Transactions"
  from v$rollstat
/
prompt 'Total Number of Rollback Waits Since the Instance Started' 
select class, count 
 from v$waitstat
where class like '%undo%'
/

prompt 'More Rollback segment stats'
SELECT name, gets, waits,
       ((gets - waits) * 100) / gets hit_ratio
FROM   v$rollstat S,
       v$rollname R
WHERE  S.usn = R.usn
/

prompt 'Even More Rollback segment stats'
select name, optsize, shrinks, aveshrink, wraps, extends
from V$ROLLSTAT, V$ROLLNAME
where V$ROLLSTAT.usn = V$ROLLNAME.usn
/

