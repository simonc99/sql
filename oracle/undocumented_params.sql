col PARAMETER for a40
col "SESSION VALUE" for a25
col "INSTANCE VALUE" for a25
select a.ksppinm  "PARAMETER", b.ksppstvl "SESSION VALUE", c.ksppstvl "INSTANCE VALUE"
  from x$ksppi a, x$ksppcv b, x$ksppsv c
 where a.indx = b.indx and a.indx = c.indx
   and substr(ksppinm,1,1)='_'
order by a.ksppinm;
