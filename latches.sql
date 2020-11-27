
prompt     Returns the largest percentage of latch contention from key latches. Should be less than 3%. If value > 3%,
prompt     try decreasing the value of the init.ora parameter LOG_SMALL_ENTRY_MAX_SIZE to force more
prompt     copies to use the copy latches. For multiple CPU systems, increase the number of redo copy latched by
prompt     increasing the value of the init.ora parameter LOG_SIMULTANEOUS_COPIES. It may be helpful to
prompt     have up to twice as many copy latches as CPUs available to the data base instance. Finally, try increasing
prompt     the value of the init.ora parameter LOG_ENTRY_PREBUILD_THRESHOLD.

     select round(greatest(
     (sum(decode(ln.name, 'cache buffers lru chain', misses,0))
     / greatest(sum(decode(ln.name, 'cache buffers lru chain', gets,0)),1)),
     (sum(decode(ln.name, 'enqueues', misses,0))
     / greatest(sum(decode(ln.name, 'enqueues', gets,0)),1)),
     (sum(decode(ln.name, 'redo allocation', misses,0))
     / greatest(sum(decode(ln.name, 'redo allocation', gets,0)),1)),
     (sum(decode(ln.name, 'redo copy', misses,0))
     / greatest(sum(decode(ln.name, 'redo copy', gets,0)),1)))
     * 100,2) pctge
     from v$latch l, v$latchname ln
     where l.latch# = ln.latch#;

prompt     Displays a report showing a row for each current latch. Latches protect shared data structures in the SGA.
prompt     A user or background process acquires a latch when working with a structure. The latch is released when
prompt     the user or process finishes with the structure. Each latch protects a different set of data, as identified by the
prompt     latch name. The latch report shows the process currently holding the latch and the ratios of waits and
prompt     timeouts per request.
prompt     name - Latch name.
prompt     pid - Identifier of the process holding the latch.
prompt     immediate_gets - Number of times obtained latch with no wait.
prompt     immediate_misses - Number of times failed to obtained latch and user or process was not willing to wait
prompt     for the latch.
prompt     gets - Number of latches obtained after a wait.
prompt     misses - Number of latches obtained, after a failure on the first attempt and a subsequent wait.
prompt     sleeps - Number of times a process or user timed-out while waiting for a latch
col a1 form a30
     select ln.name a1,
     lh.pid,
     l.immediate_gets,
     l.immediate_misses,
     l.gets,
     l.misses,
     l.sleeps
     from v$latch l, v$latchholder lh, v$latchname ln
     where l.latch# = ln.latch#
     and l.addr = lh.laddr(+)
     order by l.level#, l.latch#;

prompt     Returns the percent of time that a request for a latch was statisfied, although not necessarily immediately.
     select round(((sum(l.immediate_gets) + sum(l.misses) + sum(l.gets))
     / (sum(l.immediate_gets) + sum(l.immediate_misses) + sum(l.gets) + sum(l.misses))) * 100,2) pctge
     from v$latch l;

prompt     Returns the percent of time that a request for a latch was immediately statisfied.
     select round((sum(l.immediate_gets)
     / (sum(l.immediate_gets) + sum(l.immediate_misses) + sum(l.gets) + sum(l.misses))) * 100,2) pctge
     from v$latch l;

prompt     Displays a report showing aggregate latch data. Latches protect shared data structures in the SGA. A user
prompt     or background process acquires a latch when working with a structure. The latch is released when the user
prompt     or process finishes with the structure. Each latch protects a different set of data, as identified by the latch
prompt     name. The latch report shows the process currently holding the latch and the ratios of waits and timeouts
prompt     per request.
prompt     immediate_gets - Total number of latches obtained with no wait.
prompt     immediate_misses - Total number of times user or process failed to obtain a latch or was not willing to
prompt     wait for the latch.
prompt     gets - Total number of latches obtained after a wait.
prompt     misses - Total number of latches obtained, after a failure on the first attempt and a subsequent wait.
prompt     sleeps - Total number of times a process or user timed-out while waiting for a latch.
     select sum(l.immediate_gets),
     sum(l.immediate_misses),
     sum(l.gets),
     sum(l.misses),
     sum(l.sleeps)
     from v$latch l, v$latchholder lh, v$latchname ln
     where l.latch# = ln.latch#
     and l.addr=lh.laddr(+);

prompt     The percentage of time that a process attempted to acquire a redo log latch held by another process.
prompt     Should be < 1%. Rare on single CPU systems. If value > 1%, try decreasing the value of the init.ora
prompt     parameter LOG_SMALL_ENTRY_MAX_SIZE to reduce contention for the redo allocation latch. For
prompt     multiple CPU systems, increase the number of redo copy latched by increasing the value of the init.ora
prompt     parameter LOG_SIMULTANEOUS_COPIES. It may be helpful to have up to twice as many copy
prompt     latches as CPUs available to the data base instance. Additionally, try increasing the value of the init.ora
prompt     parameter LOG_ENTRY_PREBUILD_THRESHOLD.
     select round(greatest(
     (sum(decode(ln.name, 'redo copy', misses,0))
     / greatest(sum(decode(ln.name, 'redo copy', gets,0)),1)),
     (sum(decode(ln.name, 'redo allocation', misses,0))
     / greatest(sum(decode(ln.name, 'redo allocation', gets,0)),1)),
     (sum(decode(ln.name, 'redo copy', immediate_misses,0))
     / greatest(sum(decode(ln.name, 'redo copy', immediate_gets,0))
     + sum(decode(ln.name, 'redo copy', immediate_misses,0)),1)),
     (sum(decode(ln.name, 'redo allocation', immediate_misses,0))
     / greatest(sum(decode(ln.name, 'redo allocation', immediate_gets,0))
     + sum(decode(ln.name, 'redo allocation', immediate_misses,0)),1)))
     * 100,2) pctge
     from v$latch l, v$latchname ln
     where l.latch# = ln.latch#;


SELECT name, gets, misses, immediate_gets, immediate_misses
FROM   v$latch
WHERE  name in ('redo allocation', 'redo copy') ;
