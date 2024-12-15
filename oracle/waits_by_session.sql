break on sid on username skip 1 page
set pages 4000 lines 400 trimspool on trimout on
select  A.SID,
        B.USERNAME,
        A.SEQ#,
        A.EVENT,
        A.WAIT_TIME
from    V$SESSION_WAIT_HISTORY A,
        V$SESSION B
where   A.SID = B.SID and
        B.USERNAME IS NOT NULL and
	B.USERNAME NOT IN ('SYS','SYSTEM')
order by 1,3
/
