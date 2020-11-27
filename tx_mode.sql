select l.inst_id,l.SID,program c1,l.TYPE,l.ID1,l.ID2,l.LMODE,l.REQUEST  from gv$lock l,gv$session s  where l.type like 'TX' and l.REQUEST =6  and l.inst_id=s.inst_id and l.sid=s.sid  order by id1

/
