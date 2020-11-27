delete	from plan_table;
explain plan
set 	statement_id = 'SQL1' for
select	to_char(sysdate, 'MM/DD/YY HH:MM AM'), 
	to_char((trunc((sysdate -4, -1), 'day') +1), 'DD-MON-YY'),
from	bk, ee
where	bk_shift_date >= to_char((trunc(( sysdate - 4 - 1), 'day' + 1),
                         'DD-MON-YY')
and	bk_shift_date <= to_char((sysdate - 4), 'DD-MON-YY')
and	bk_empno = ee_empno (+)
and	substr( ee_hierarchy_code, 1, 3) in ('PNA', 'PNB', 'PNC',
                                             'PND', 'PNE', 'PNF')
order by ee_job_group, 
	 bk_empno,
	 bk_shift_date
/
select	LPad(' ', 2*(Level-1)) || Level || '.' || nvl(Position,0) ||
        ' ' || Operation || ' ' || Options || ' ' || Object_Name ||
        ' ' || Object_Type || ' ' || Decode(id, 0, Statement_id ||  
        'Cost = ' || Position) || Other || ' ' || 
	Object_Node "Query Plan"
from	plan_table
start	with id = 0
and 	statement_id = 'SQL1'
connect by prior id = parent_id
and	statement_id = 'SQL1'
/

