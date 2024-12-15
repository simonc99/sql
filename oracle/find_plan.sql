/*
 * Find a query plan for all current cursors
 * with a particular table mentioned
 *
 * SCC 
 *
 * Requires 10g / 11g - uses DBMS_XPLAN
 *
 */

SET LINESIZE 150 PAGESIZE 50000 VERIFY OFF

ACCEPT TNAME PROMPT 'Enter table name : '

SELECT 
	T.*
FROM 
	V$SQL S, 
	TABLE(DBMS_XPLAN.DISPLAY_CURSOR(S.SQL_ID, S.CHILD_NUMBER)) T
WHERE 
	UPPER(SQL_TEXT) LIKE UPPER('%&TNAME%')
AND
	S.EXECUTIONS > 0
ORDER BY
	S.DISK_READS/S.EXECUTIONS;
