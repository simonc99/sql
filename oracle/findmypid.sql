select a.sid, b.spid from v$session a, v$process b where
a.paddr = b.addr
and sid = (select distinct sid from v$mystat)
/
