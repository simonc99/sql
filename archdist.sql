rem -----------------------------------------------------------------------
rem Filename:   archdist.sql
rem Purpose:    Tabular display of redo-log archiving history (logs/hour)
rem             - Can only run from sqlplus
rem Author:     Frank Naude (frank@onwe.co.za)
rem -----------------------------------------------------------------------

set pagesize 50000
set line 132
set veri off echo off

set termout off
def time="time"                    -- Oracle7
col time new_value time
select 'to_char(first_time,''MM/DD/YY HH24:MI:SS'')' time
from   dual
where  &&_O_RELEASE like '8%'      -- Oracle8
or     &&_O_RELEASE like '9%'      -- Oracle9
or     &&_O_RELEASE like '10%'     -- Oracle10
or     &&_O_RELEASE like '11%'     -- Oracle11
/
set termout on

select substr(&&time, 1, 5) day,
       to_char(sum(decode(substr(&&time,10,2),'00',1,0)),'99') "00",
       to_char(sum(decode(substr(&&time,10,2),'01',1,0)),'99') "01",
       to_char(sum(decode(substr(&&time,10,2),'02',1,0)),'99') "02",
       to_char(sum(decode(substr(&&time,10,2),'03',1,0)),'99') "03",
       to_char(sum(decode(substr(&&time,10,2),'04',1,0)),'99') "04",
       to_char(sum(decode(substr(&&time,10,2),'05',1,0)),'99') "05",
       to_char(sum(decode(substr(&&time,10,2),'06',1,0)),'99') "06",
       to_char(sum(decode(substr(&&time,10,2),'07',1,0)),'99') "07",
       to_char(sum(decode(substr(&&time,10,2),'08',1,0)),'99') "08",
       to_char(sum(decode(substr(&&time,10,2),'09',1,0)),'99') "09",
       to_char(sum(decode(substr(&&time,10,2),'10',1,0)),'99') "10",
       to_char(sum(decode(substr(&&time,10,2),'11',1,0)),'99') "11",
       to_char(sum(decode(substr(&&time,10,2),'12',1,0)),'99') "12",
       to_char(sum(decode(substr(&&time,10,2),'13',1,0)),'99') "13",
       to_char(sum(decode(substr(&&time,10,2),'14',1,0)),'99') "14",
       to_char(sum(decode(substr(&&time,10,2),'15',1,0)),'99') "15",
       to_char(sum(decode(substr(&&time,10,2),'16',1,0)),'99') "16",
       to_char(sum(decode(substr(&&time,10,2),'17',1,0)),'99') "17",
       to_char(sum(decode(substr(&&time,10,2),'18',1,0)),'99') "18",
       to_char(sum(decode(substr(&&time,10,2),'19',1,0)),'99') "19",
       to_char(sum(decode(substr(&&time,10,2),'20',1,0)),'99') "20",
       to_char(sum(decode(substr(&&time,10,2),'21',1,0)),'99') "21",
       to_char(sum(decode(substr(&&time,10,2),'22',1,0)),'99') "22",
       to_char(sum(decode(substr(&&time,10,2),'23',1,0)),'99') "23"
from   sys.v_$log_history
group  by substr(&&time,1,5)
order by 1
/
