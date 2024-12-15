set lines 2000 trimspool on trimout on pages 4000
col constraint_name for a30 trunc
col column_name for a30 trunc
col table_name for a45 trunc
spool unindexed_fk.log
select /*+ ordered */
  n.name  constraint_name,
  u.name ||'.'|| o.name  table_name,
  c.name  column_name
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
  n.con# = fk.con# 
order by
  2, 1, 3;
spool off
