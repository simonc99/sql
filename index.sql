column column_name for a30 trunc
set verify off pages 4000 lines 100 trimspool on trimout on
break on index_name skip page
select index_name, column_name from dba_ind_columns where
table_name = upper('&&1')
order by 1, column_position;

