select used_urec from v$session s, v$transaction t
where
s.taddr = t.addr
/
