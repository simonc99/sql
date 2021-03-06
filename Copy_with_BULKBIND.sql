-- Anonymous PL/SQL block to bulk-bind transfer a table with LONG / LONG RAW datatype(s)

-- Indexes are NOT copied. 

-- First, create a table, named <TABLE_NAME>_REORG, with the same structure as the thing you're copying...
-- obviously this needs to be done manually, as we're copying a LONG / LONG RAW. The DDL produced will
-- NOT include STORAGE parameters :

-- e.g.,
-- COL XXX FOR A132 WORD_WRAPPED
-- SET LINES 132 PAGES 0 HEADING OFF FEEDBACK OFF
-- SELECT DBMS_METADATA.GET_DDL('TABLE','<TABLE_NAME>','<OWNER>') XXX FROM DUAL;
-- SET FEEDBACK ON TIMING ON

-- Watch out for paging... The combination of COMMIT_LIMIT and COPY_REC LIMIT are critical

SPOOL bulk_copy.log

SET SERVEROUTPUT ON SIZE 1000000;

DECLARE 
TYPE COPYRECTAB IS TABLE OF "<OWNER>"."<TABLE_NAME>"%ROWTYPE;
COPY_REC COPYRECTAB;
ROWS_COPIED INTEGER:=0;
COMMIT_LIMIT INTEGER:=0;

CURSOR C1 IS
	SELECT  *
	FROM "<OWNER>"."<TABLE_NAME>"; 

BEGIN 
	OPEN C1;
	LOOP
		FETCH C1 BULK COLLECT INTO COPY_REC LIMIT 250000;
	EXIT WHEN C1%NOTFOUND;

	FORALL I IN COPY_REC.FIRST..COPY_REC.LAST
		INSERT INTO "<OWNER>"."<TABLE_NAME>_REORG" VALUES COPY_REC(I);
		ROWS_COPIED:=(SQL%ROWCOUNT+ROWS_COPIED);
		COMMIT_LIMIT:=ROWS_COPIED;
		IF (COMMIT_LIMIT > 1000000)
		THEN
			COMMIT;
			COMMIT_LIMIT:=0 ;
		END IF;
	END LOOP;

	FORALL I IN COPY_REC.FIRST..COPY_REC.LAST SAVE EXCEPTIONS
		INSERT INTO "<OWNER>"."<TABLE_NAME>_REORG" VALUES COPY_REC(I);
		ROWS_COPIED:=(SQL%ROWCOUNT+ROWS_COPIED);
		DBMS_OUTPUT.PUT_LINE('TOTAL ROWS TRANSFERRED : '||ROWS_COPIED);
			EXCEPTION
			WHEN OTHERS THEN
				DBMS_OUTPUT.PUT_LINE('TOTAL ROWS TRANSFERRED : '||ROWS_COPIED);
	CLOSE C1;
COMMIT;
END;
/

-- ALTER TABLE <OWNER>.<TABLE_NAME> TO <OWNER>.<TABLE_NAME>_OLD;
-- ALTER TABLE <OWNER>.<TABLE_NAME>_REORG TO <OWNER>.<TABLE_NAME>;

SPOOL OFF
