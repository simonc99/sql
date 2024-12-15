select
'| Operation                                               |  Name         |  Rows | Bytes|  Cost  | Pstart| Pstop |'
as "Plan Table" from dual
union all
select
'-------------------------------------------------------------------------------------------------------------------'
from dual
union all
select * from
(select /*+ no_merge */
       rpad('| '||substr(lpad(' ',1*(level-1))||operation||
            decode(options, null,'',' '||options), 1, 57), 58, ' ')||'|'||
       rpad(substr(object_name||' ',1, 15), 15, ' ')||'|'||
       lpad(decode(cardinality,null,'  ',
            decode(sign(cardinality-1000), -1, cardinality||' ',
            decode(sign(cardinality-1000000), -1,
trunc(cardinality/1000)||'K',
            decode(sign(cardinality-1000000000), -1,
trunc(cardinality/1000000)||'M',
               trunc(cardinality/1000000000)||'G')))), 7, ' ') || '|' ||
       lpad(decode(bytes,null,' ',
                decode(sign(bytes-1024), -1, bytes||' ',
                decode(sign(bytes-1048576), -1, trunc(bytes/1024)||'K',
                decode(sign(bytes-1073741824), -1,
trunc(bytes/1048576)||'M',
                       trunc(bytes/1073741824)||'G')))), 6, ' ') || '|' ||
       lpad(decode(cost,null,' ',
                decode(sign(cost-10000000), -1, cost||' ',
                decode(sign(cost-1000000000), -1, trunc(cost/1000000)||'M',
                       trunc(cost/1000000000)||'G'))), 8, ' ') || '|' ||
       lpad(decode(partition_start, 'ROW LOCATION', 'ROWID',
            decode(partition_start, 'KEY', 'KEY', decode(partition_start,
            'KEY(INLIST)', 'KEY(I)', decode(substr(partition_start, 1, 6),
            'NUMBER', substr(substr(partition_start, 8, 10), 1,
            length(substr(partition_start, 8, 10))-1),
            decode(partition_start,null,' ',partition_start)))))||
                      ' ', 7, ' ')|| '|' ||
       lpad(decode(partition_stop, 'ROW LOCATION', 'ROW L',
          decode(partition_stop, 'KEY', 'KEY', decode(partition_stop,
          'KEY(INLIST)', 'KEY(I)', decode(substr(partition_stop, 1, 6),
          'NUMBER', substr(substr(partition_stop, 8, 10), 1,
          length(substr(partition_stop, 8, 10))-1),
          decode(partition_stop,null,' ',partition_stop))))) ||
          ' ', 7, ' ')|| '|' as "Explain plan"
from v$sql_plan
start with (address = '&1'
            and hash_value = &2     
            and child_number = &3      
            and id=0 )
connect by prior id = parent_id
        and prior address = address
        and prior hash_value = hash_value
        and prior child_number = child_number
order by id, position)
union all
select
'-------------------------------------------------------------------------------------------------------------------'
from dual;
