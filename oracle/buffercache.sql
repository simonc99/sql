prompt     The init.ora parameter: DB_BLOCK_BUFFERS controls the amount of memory allocated for the data
prompt     cache. When an application requests data, Oracle first attempts to find it in the data cache. The more often
prompt     Oracle finds requested data in memory a physical IO is avoided, and thus overall performance is better.
prompt     Under normal circumstances this ratio should be >= 95%. Initially set the DB_BLOCK_BUFFERS size to
prompt     be 20 - 50% the size of the SGA.
prompt#

select round((1-(pr.value/(bg.value+cg.value)))*100,2)
     from v$sysstat pr, v$sysstat bg, v$sysstat cg
     where pr.name = 'physical reads'
     and bg.name = 'db block gets'
     and cg.name = 'consistent gets';

prompt The Hit Ratio
prompt #

select 
       sum(decode(name, 'consistent gets',value, 0))  "Consis Gets",
        sum(decode(name, 'db block gets',value, 0))  "DB Blk Gets",
        sum(decode(name, 'physical reads',value, 0))  "Phys Reads",
       (sum(decode(name, 'consistent gets',value, 0))  +
        sum(decode(name, 'db block gets',value, 0))  -
        sum(decode(name, 'physical reads',value, 0)))
		       /
       (sum(decode(name, 'consistent gets',value, 0))  +
        sum(decode(name, 'db block gets',value, 0))  )  * 100 "Hit Ratio" 
from v$sysstat st
/

prompt User Hit Ratios with Hit Ratio < 80%

column nl newline;
column "Hit Ratio" format 999.99
column  "User Session" format a15;

select  se.username||'('|| se.sid||')' "User Session",
       sum(decode(name, 'consistent gets',value, 0))  "Consis Gets",
        sum(decode(name, 'db block gets',value, 0))  "DB Blk Gets",
        sum(decode(name, 'physical reads',value, 0))  "Phys Reads",
       (sum(decode(name, 'consistent gets',value, 0))  +
        sum(decode(name, 'db block gets',value, 0))  -
        sum(decode(name, 'physical reads',value, 0)))
		       /
       (sum(decode(name, 'consistent gets',value, 0))  +
        sum(decode(name, 'db block gets',value, 0))  )  * 100 "Hit Ratio" 
  from  v$sesstat ss, v$statname sn, v$session se
where   ss.sid    = se.sid
  and   sn.statistic# = ss.statistic#
  and   value != 0
  and   sn.name in ('db block gets', 'consistent gets', 'physical reads')
group by se.username, se.sid
having 
       (sum(decode(name, 'consistent gets',value, 0))  +
        sum(decode(name, 'db block gets',value, 0))  -
        sum(decode(name, 'physical reads',value, 0)))
		       /
       (sum(decode(name, 'consistent gets',value, 0))  +
        sum(decode(name, 'db block gets',value, 0))  )  * 100 
  <   80
;

prompt The Average Length of the Write Request Queue

column  "Write Request Length" format 999,999.99

select sum( decode (name, 'summed dirty queue length', value))
               /
       sum( decode (name, 'write requests', value)) "Write Request Length"
  from v$sysstat
 where  name in ( 'summed dirty queue length'
                 ,'write requests')
   and  value > 0
/

prompt Cache hit ratio = physical reads/(db_block gets + consistent gets )
prompt If cache hit ratio > 0.6, increase DB_BLOCK_BUFFERS

select V1.value/(V2.value + V3.value) from V$SYSSTAT V1, V$SYSSTAT V2, V$SYSSTAT V3
where V1.name = 'physical reads' and V2.name = 'db block gets' and V3.name = 'consistent gets';

