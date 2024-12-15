

prompt     SGA Size 

     select sum(value) size_bytes,
            sum(value)/(1024*1024) size_mbytes
     from v$sga;

prompt 'System Global Area Breakdown'

select *      
  from v$sgastat
/


prompt     Returns 
prompt         the amount of free space in the SGA. 
prompt         Percentage of free space in the SGA.
prompt
prompt     Ideally, all available space is used to a maximum efficiency,
prompt     Some authorities recommend letting free space become no less than 5%.
prompt     so the SGA would have no free space. Unless the data base has been tuned, however, a shortage of free
prompt     space may indicate an SGA that is too small. This query type is helpful during tuning of the SGA size.

     select sum(decode(name, 'free memory', bytes, 0)) sum_free,
            round((sum(decode(name, 'free memory', bytes, 0))/ sum(bytes)) * 100,0) pctge_free
     from   v$sgastat;

