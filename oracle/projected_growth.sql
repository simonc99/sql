set linesize 132 pagesize 100
select to_char(trunc(TIMEPOINT),'YYYYMMDD') "DATE", SPACE_USAGE/1024 "KB USED", SPACE_ALLOC/1024 "KB ALLOCATED", QUALITY
from
table(dbms_space.object_growth_trend('TRENTADM','ET_STATE','TABLE',NULL,NULL,SYSTIMESTAMP+30,INTERVAL '1' DAY))
order by timepoint
/
