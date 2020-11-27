-------------------------------------------------------------------------------
--
-- Script:	lgwr_stats.sql
-- Purpose:	to show if the log_buffer is well sized
-- For:		8.0 and 8.1
--
--
-- Description: These statistics show whether the log_buffer is well sized.
--
-------------------------------------------------------------------------------

set termout off
set lines 100
set pages 100
column log_block_size new_value LogBlockSize
select
  max(lebsz) log_block_size
from
  sys.x$kccle
where
  inst_id = userenv('Instance')
/
set termout on

column write_size format 99999999999999 heading "Average Log|Write Size"

select
  ceil(max(decode(name, 'redo blocks written', value))
      /max(decode(name, 'redo writes', value, 1)))
  * &LogBlockSize  write_size
from
  sys.v_$sysstat
/

column threshold  format 99999999999999 heading "Background|Write Theshold"

select
  least(ceil(value/&LogBlockSize/3) * &LogBlockSize, 1024*1024)  threshold
from
  sys.v_$parameter
where
  name = 'log_buffer'
/

column sync_cost_ratio format 990.00 heading "Sync Cost Ratio"

select
  (sum(decode(name, 'redo synch time', value)) / sum(decode(name, 'redo synch writes', value)))
  / (sum(decode(name, 'redo write time', value)) / sum(decode(name, 'redo writes', value)))
    sync_cost_ratio
from
  sys.v_$sysstat
where
  name in ('redo synch writes', 'redo synch time', 'redo writes', 'redo write time')
/

