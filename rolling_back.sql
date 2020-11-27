col sql_text for a60 word_wrapped
select sql_text, used_ublk
  from v$sqlarea vsa,
       v$session vs,
       v$transaction vt
 where vsa.address = vs.sql_address
   and vsa.hash_value = vs.sql_hash_value
   and vs.taddr = vt.addr
   and bitand(vt.flag,power(2,7))>0
/
