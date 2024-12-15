-------------------------------------------------------------------------------
--
-- Script:	post_smon.sql
-- Purpose:	to post the SMON background process (to cleanup temps)
--
-- Copyright:	(c) 1998 Ixora Pty Ltd
-- Author:	Steve Adams (with acknowledgements to Jonathan Lewis)
--
-------------------------------------------------------------------------------
prompt Getting process id of SMON.
column pid new_value pid
select
  p.pid
from
  sys.v_$process p
where
  p.program like '%(SMON)'
/
prompt Calling svrmgrl to post SMON.
host echo "connect internal\noradebug wakeup &pid" | svrmgrl | grep "SVRMGR>"
clear columns
