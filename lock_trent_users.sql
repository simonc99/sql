-- Locks all iTrent users, keeping a list of those already inactive.
-- Runs against all users except SYSADMIN and list given...

-- Run from sqlplus or similar, as TRENTADM or DBA privileged user 

-- Script exits on error

WHENEVER SQLERROR EXIT FAILURE;

CREATE TABLE UTIL.INACTIVE_USERS AS SELECT * FROM TRENTADM.TUSER WHERE ACTIVE_SWITCH = 'F';

COMMIT;

UPDATE TRENTADM.TUSER SET ACTIVE_SWITCH = 'F' WHERE USER_NM NOT IN (
'SYSADMIN');

COMMIT;
