SELECT * FROM (
SELECT
event
, TRIM(TO_CHAR(p1, 'XXXXXXXXXXXXXXXX')) latch_addr
, TRIM(ROUND(RATIO_TO_REPORT(COUNT(*)) OVER () * 100, 1))||'%' PCT
, COUNT(*)
FROM
v$active_session_history
WHERE
event = 'latch: cache buffers chains'
AND session_state = 'WAITING'
GROUP BY
event
, p1
ORDER BY
COUNT(*) DESC
)
WHERE ROWNUM <= 10
/
