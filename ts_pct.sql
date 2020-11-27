SELECT 	A.TABLESPACE_NAME,
	A.BYTES BYTES_USED,
	B.BYTES BYTES_FREE,
	B.LARGEST,
	ROUND(((A.BYTES-B.BYTES)/A.BYTES)*100,2) PERCENT_USED,
	(100-ROUND(((A.BYTES-B.BYTES)/A.BYTES)*100,2)) PERCENT_FREE
FROM
	(SELECT TABLESPACE_NAME, SUM(BYTES) BYTES 
		FROM DBA_DATA_FILES GROUP BY TABLESPACE_NAME) A,
	(SELECT TABLESPACE_NAME, SUM(BYTES) BYTES, MAX(BYTES) LARGEST 
		FROM DBA_FREE_SPACE GROUP BY TABLESPACE_NAME) B
WHERE 
	A.TABLESPACE_NAME=B.TABLESPACE_NAME
AND 
	A.TABLESPACE_NAME IN (
		SELECT DISTINCT TABLESPACE_NAME 
			FROM DBA_TABLESPACES WHERE CONTENTS = 'PERMANENT')
AND 
	(100-ROUND(((A.BYTES-B.BYTES)/A.BYTES)*100,2)) < 50
/
