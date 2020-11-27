column "RBS NAME" format a24
column "SYSTEM PID" format a10
column "USERNAME" format a8
column "LOGIN ID" format a8
column "TERMINAL" format a12
column "SQL_TEXT" format a63 truncate
column USN format 999

SELECT r.name "RBS NAME",
	r.usn, 
        l.sid "ORACLE PID", p.spid "SYSTEM PID",
        NVL ( s.username, 'NO TRANSACTION' ) USERNAME,
        NVL ( s.osuser, '----' ) "LOGIN ID",
        s.terminal TERMINAL, a.sql_text
 FROM v$lock l, v$process p, v$session s, v$rollname r, v$sqlarea a
  WHERE l.sid = s.sid(+) AND TRUNC (l.id1(+)/65536) = r.usn
    AND l.type(+) = 'TX' AND l.lmode(+) = 6 
    AND s.paddr = p.addr
    and S.SQL_ADDRESS  = a.ADDRESS(+)
    and S.SQL_HASH_VALUE = a.HASH_VALUE(+)
    ORDER BY r.name;
