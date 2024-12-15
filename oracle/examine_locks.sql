select * from v$lock where sid != (select distinct sid from v$mystat)
and id1 = (select id1 from v$lock where sid != (select distinct sid from v$mystat) and id2 != 0)
/
