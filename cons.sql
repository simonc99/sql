
     declare 
     cursor c1 is  
     select c.constraint_name,c.r_constraint_name cname2, 
            c.table_name table1, r.table_name table2, 
            decode(c.status,'DISABLED','DISABLE',' ') status, 
            decode(c.delete_rule,'CASCADE',' on delete cascade ',' ')  
     delete_rule 
     from   user_constraints c, 
            user_constraints r 
     where c.constraint_type='R' and 
           c.r_constraint_name = r.constraint_name and 
           c.table_name = upper('&1')  
     union 
     select c.constraint_name,c.r_constraint_name cname2, 
            c.table_name table1, r.table_name table2, 
            decode(c.status,'DISABLED','DISABLE',' ') status, 
            decode(c.delete_rule,'CASCADE',' on delete cascade ',' ')  
     delete_rule 
     from   user_constraints c, 
            user_constraints r 
     where c.constraint_type='R' and 
           c.r_constraint_name = r.constraint_name and 
           r.table_name = upper('&1'); 
     cname varchar2(50); 
     cname2 varchar2(50); 
     cursor c2 is  
     select decode(position,1,'(',',')||rpad(column_name,40) colname 
     from user_cons_columns 
     where   constraint_name = cname 
     order by position; 
     cursor c3 is 
     select decode(position,1,'(',',')||rpad(column_name,40) refcol 
     from user_cons_columns  
     where constraint_name = cname2 
     order by position; 
     begin 
     dbms_output.enable(100000); 
     for q1 in c1 loop 
      cname := q1.constraint_name; 
      cname2 := q1.cname2; 
      dbms_output.put_line('alter table '||q1.table1||' add constraint '); 
      dbms_output.put_line(cname||' foreign key'); 
      for q2 in c2 loop 
        dbms_output.put_line(q2.colname); 
      end loop; 
      dbms_output.put_line(') references '||q1.table2); 
      for q3 in c3 loop 
        dbms_output.put_line(q3.refcol); 
      end loop; 
      dbms_output.put_line(') '||q1.delete_rule||q1.status); 
      dbms_output.put_line('/'); 
     end loop; 
     end; 
     / 
      
