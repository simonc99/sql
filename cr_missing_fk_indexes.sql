set heading off feedback off verify off lines 300 trimspool on trimout on pages 4000 echo off
spool /tmp/cr_missing_indexes.sql
select /*+ ordered */ 'CREATE INDEX '||u.name||'.UOP_'||SUBSTR(o.name,1,22)||'_IDX ON '||u.name||'.'||o.name||'('||c.name||') TABLESPACE QUERCUS_IDX;'
from
  (
    select /*+ ordered */ distinct
      cd.con#,
      cd.obj#
    from
      sys.cdef$  cd,
      sys.tab$  t
    where
      cd.type# = 4 and			-- foriegn key
      t.obj# = cd.robj# and
      bitand(t.flags, 6) = 0 and	-- table locks enabled
      not exists (			-- not indexed
	select
	  null
	from
	  sys.ccol$  cc,
          sys.ind$  i,
	  sys.icol$  ic
	where
          cc.con# = cd.con# and
          i.bo# = cc.obj# and
          bitand(i.flags, 1049) = 0 and 	-- index must be valid
          ic.obj# = i.obj# and
	  ic.intcol# = cc.intcol#
        group by
          i.obj#
        having
          sum(ic.pos#) = (cd.cols * cd.cols + cd.cols)/2
      )
  )  fk,
  sys.obj$  o,
  sys.user$  u,
  sys.ccol$  cc,
  sys.col$  c,
  sys.con$  n
where
  o.obj# = fk.obj# and
  o.owner# != 0 and			-- ignore SYS
  u.user# = o.owner# and
  cc.con# = fk.con# and
  c.obj# = cc.obj# and
  c.intcol# = cc.intcol# and
  n.con# = fk.con# and
  n.name in (select constraint_name from dba_constraints where r_constraint_name in
		(select r_constraint_name from dba_constraints where table_name in
		('UOP_ISAM_TRANSACTION','STUDENT_COURSE_DETAIL_TABLE','STUDENT_COURSE_DETAIL_EXTENDED')))
order by
o.name, c.name
/
spool off
