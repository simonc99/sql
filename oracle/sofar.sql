set lines 132 pages 4000 trimspool on trimout on

col username for a14
col sql_text for a40 word_wrapped

select username, sql_text, sofar, totalwork, units
from v$sql, v$session_longops
where
sql_address = address and
sql_hash_value = hash_value and
sofar != totalwork
order by address, hash_value, child_number
/