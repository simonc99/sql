prompt     The number of times a user process waited for redo log buffer space. Should be near 0. If value increments
prompt     consistently, increase the size of the redo log buffer with the init.ora parameter: LOG_BUFFER by 5%.

     select value from v$sysstat where name = 'redo log space wait time';

prompt     Returns various information regarding the redo logs.
prompt     Block Writes - Total number of redo log blocks written.
prompt     Entries - Number of redo log entries.
prompt     Size - Size of the redo log.
prompt     Space Requests - Number of redo log space requests.
prompt     Synch Writes - Number of redo log synch writes.
prompt     Writes - Number of redo log writes.

     select sum(decode(name,'redo blocks written', value,0)) "Block Writes",
     sum(decode(name,'redo entries', value, 0)) "Entries",
     sum(decode(name,'redo size', value, 0)) "Size",
     sum(decode(name,'redo log space requests', value, 0)) "Space Requests",
     sum(decode(name,'redo synch writes', value,0)) "Synch Writes",
     sum(decode(name,'redo writes', value,0)) "Writes"
     from v$sysstat;

