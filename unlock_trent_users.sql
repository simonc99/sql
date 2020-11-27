-- Unlocks all iTrent users

WHENEVER SQLERROR EXIT FAILURE;

UPDATE TRENTADM.TUSER SET ACTIVE_SWITCH = 'T' WHERE USER_NM NOT IN (
SELECT USER_NM FROM UTIL.INACTIVE_USERS) AND
USER_NM != 'SYSADMIN';

DROP TABLE UTIL.INACTIVE_USERS;

COMMIT;
