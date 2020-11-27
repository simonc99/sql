
prompt     The init.ora parameter: SHARED_POOL_SIZE controls the amount of memory allocated for the shared
prompt     buffer pool. The shared buffer pool contains SQL and PL/SQL statements (library cache), the data
prompt     dictionary cache, and information on data base sessions. This percentage will never equal 100 because the
prompt     cache must perform an initial load when Oracle first starts up. The percentage, therefore, should continually
prompt     get closer to 100 as the system stays "up." Ideally, the entire data dictionary would be cached in memory.
prompt     Initially set the SHARED_POOL_SIZE to be 50-100% the size of the init.ora parameter:
prompt     DB_BLOCK_BUFFERS - then fine tune the parameter.

select round(sum(gets)/(sum(gets)+sum(getmisses)) * 100,2) from v$rowcache;


prompt     The percentage that a SQL statement did not need to be reloaded because it was already in the library
prompt     cache. The init.ora parameter: SHARED_POOL_SIZE controls the amount of memory allocated for the
prompt     shared buffer pool. The shared buffer pool contains SQL and PL/SQL statements (library cache), the data
prompt     dictionary cache, and information on data base sessions. The percentage should be = 100, for maximum
prompt     efficiency requires that no SQL statement should be reloaded and reparsed. Initially set the
prompt     SHARED_POOL_SIZE to be 50-100% the size of the init.ora parameter: DB_BLOCK_BUFFERS -
prompt     then fine tune the parameter.

     select round(sum(pinhits)/sum(pins) * 100,2) from v$librarycache;


     Returns the percentage of time that SQL statements were reloaded. Reloads occur when library objects
     have been aged out or invalidated.

     select round((1 - (sum(reloads) / sum(pins))) * 100, 2) pctge_reloads from v$librarycache;


promptAfter the database has been in use for some time, the ratio of items not retrieved from cache : items retrieved from cahe
prompt( getmisses/gets ) should be < 0.15.  
promptIf the ratio is higher, consider increasing the size of the SGA ( = db_block size * db_block_buffers )
promptThe following gives the size of items in the SGA.

select parameter, gets, getmisses, decode(getmisses, 0, 0, getmisses/gets) ratio, scans, scanmisses, modifications, count, usage
from V$ROWCACHE where gets !=0 or scans != 0 or modifications != 0 order by 4 desc;


promptPinhitratio should be close to 1

select * from V$LIBRARYCACHE;


