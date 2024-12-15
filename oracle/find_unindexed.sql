select case when i.index_name is not null
            then 'OK'
            else '****'
       end ok
     , c.table_name
     , c.constraint_name
     , c.cols
     , i.index_name
from (
  select a.table_name
       , a.constraint_name
       , listagg(b.column_name, ' ' ) 
          within group (order by column_name) cols
      from user_constraints a, user_cons_columns b
     where a.constraint_name = b.constraint_name
       and a.constraint_type = 'R'
  group by a.table_name, a.constraint_name
 ) c
 left outer join
 (
  select table_name
       , index_name
       , cr
       , listagg(column_name, ' ' ) 
          within group (order by column_name) cols
    from (
        select table_name
             , index_name
             , column_position
             , column_name
             , connect_by_root(column_name) cr
          from user_ind_columns
       connect by prior column_position-1 = column_position
              and prior index_name = index_name
         )
    group by table_name, index_name, cr
) i on c.cols = i.cols and c.table_name = i.table_name
;
