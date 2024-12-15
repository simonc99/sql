select CHILD#  "cCHILD"
,      ADDR    "sADDR"
,      GETS    "sGETS"
,      MISSES  "sMISSES"
,      SLEEPS  "sSLEEPS"
from v$latch_children
where name = 'cache buffers chains'
order by 4, 1, 2, 3
/
