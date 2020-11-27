col "Instance Value" for a20
col "Session Value" for a20
col Parameter for a35
select a.ksppinm  "Parameter", b.ksppstvl "Session Value", c.ksppstvl "Instance Value"
  from x$ksppi a, x$ksppcv b, x$ksppsv c
 where a.indx = b.indx and a.indx = c.indx
   and substr(ksppinm,1,1)='_'
order by a.ksppinm
/
