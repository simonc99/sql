do $do$      
declare      
    i int;      
begin      
    for i in 0..99 loop      
        execute format(    
            $sql$       
                create table partitioned_table_%s       
                partition of partitioned_table       
                for values from (%s) to (%s)       
            $sql$,       
            i,       
            i * 9999 + 1,       
            (i + 1) * 9999 + 1       
        );      
            
        execute format(    
            $sql$       
                insert into partitioned_table_%s       
                select generate_series(%s, %s) as id, 'data'       
            $sql$,       
            i,       
            i * 9999 + 1,       
            (i + 1) * 9999       
        );      
            
        execute format(    
            $sql$       
                create index on partitioned_table_%s (id)       
            $sql$,       
            i       
        );      
    end loop;      
end $do$;
