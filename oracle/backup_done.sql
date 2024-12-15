col message for a60 word_wrapped
select message, time_remaining from v$session_longops where sofar != totalwork
and message like 'RMAN%'
/
