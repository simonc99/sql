WITH temp_constraints AS
(
SELECT   b.table_name
        ,a.constraint_name pkey_constraint
        ,NULL fkey_constraint
        ,NULL r_constraint_name
FROM     user_tables b LEFT OUTER JOIN user_constraints a
                        ON a.table_name = b.table_name
                        AND a.constraint_type = 'P'
UNION ALL
SELECT a.table_name
      ,a.constraint_name pkey_constraint
      ,b.constraint_name fkey_constraint
      ,b.r_constraint_name
FROM   user_constraints a, user_constraints b
WHERE  a.table_name = b.table_name
AND    a.constraint_type = 'P'
AND    b.constraint_type = 'R')
SELECT     RPAD ('*' , (LEVEL - 1) * 2 ,'*') || table_name relation
FROM       temp_constraints
START WITH fkey_constraint IS NULL
CONNECT BY pkey_constraint <> r_constraint_name
AND        PRIOR pkey_constraint = r_constraint_name;
