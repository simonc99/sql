     declare 
     cursor c1 is 
     select constraint_name, decode(constraint_type,'U',' UNIQUE',' PRIMARY  
     KEY') typ, 
     decode(status,'DISABLED','DISABLE',' ') status from user_constraints  
     where table_name = upper('&1') 
     and   constraint_type in ('U','P'); 
     cname varchar2(100); 
     cursor c2 is 
     select decode(position,1,'(',',')||rpad(column_name,40) coln 
     from user_cons_columns 
     where table_name = upper('&1') 
     and   constraint_name = cname 
     order by position; 
     begin 
     for q1 in c1 loop 
      cname := q1.constraint_name; 
      dbms_output.put_line('alter table &1'); 
      dbms_output.put_line('add constraint '||cname||q1.typ); 
for q2 in c2 loop 
dbms_output.put_line(q2.coln); 
end loop; 
dbms_output.put_line(')' ||q1.status); 
dbms_output.put_line('/'); 
end loop; 
end; 
/
