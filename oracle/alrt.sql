-------------------------------------------------------------------
--
--  Script: alert_tail.sql			     	
--  Purpose: to show tail of Alert File
--
--  Copyright:  Vladimir Demkin
--  Author:  Vladimir Demkin
--
--  Comment: Ruined by Simon Cole / Now works on Windows and Unix
--  Note   : 10g on Windows uses same alert log filename format as Unix
--	     so a version specific check needs to be made
--
-------------------------------------------------------------------
set feedback off
column value noprint new_value alert_dir
define LinNum = 50

SELECT value FROM v$parameter WHERE name='background_dump_dest';

set termout off verify off
DROP DIRECTORY alert_dir;
set termout on
CREATE DIRECTORY alert_dir AS '&alert_dir';

variable result varchar2(4000)

DECLARE
  Alert BFILE;
  TempBuf RAW(2000);
  TotBytes BINARY_INTEGER := 2000;
  FileLen INTEGER;
  Buffer LONG;
  LinNum  NUMBER:=&LinNum;
  sid VARCHAR2(8);
  i VARCHAR2(80);
  j INTEGER;
  res VARCHAR2(4000);
BEGIN
  SELECT instance_name INTO sid FROM v$instance;
  BEGIN
    SELECT BANNER INTO i FROM v$version WHERE banner like 'TNS%';
  IF i LIKE '%Windows%' THEN
    Alert:=BFILENAME('ALERT_DIR',sid||'ALRT.LOG');
  ELSE
    Alert:=BFILENAME('ALERT_DIR','alert_'||sid||'.log');
  END IF;
  END;
  DBMS_LOB.FILEOPEN(Alert);
  FileLen:=DBMS_LOB.GETLENGTH(Alert);
  IF TotBytes>FileLen THEN
    TotBytes:=0;
  END IF;
  DBMS_LOB.READ(alert,TotBytes,FileLen-TotBytes,TempBuf);
  Buffer:=UTL_RAW.CAST_TO_VARCHAR2(TempBuf);
  j:=INSTR(Buffer,CHR(10),-1,(LinNum))+1;
  :result:=SUBSTR(Buffer,j);
  DBMS_LOB.FILECLOSE(alert);
END;
/


column result heading "Tail of ALERT FILE (Last &LinNum lines)"
set heading on
set pagesize 500 lines 400 trimspool on trimout on feedback off
print result 

DROP DIRECTORY ALERT_DIR;

column result clear
column value clear
set verify on
set feedback on

