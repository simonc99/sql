select 'SELECT DBMS_METADATA.GET_DDL(''INDEX'','''||index_name||''','''||owner||''') XXX FROM DUAL;'
from dba_indexes where index_name like 'UOP%' and owner = 'QUERCUS'
/
