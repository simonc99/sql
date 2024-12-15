
set pagesize 85

col username format a10
col osuser format a15
col sid format 9999
col serial format 99999
col type format a2
col request format 9
col lmode format 9
col lmode_desc format a16
col type_desc format a30 wrap

SELECT /*+ FIRST_ROWS ORDERED */ username,
s.osuser osuser , s.sid sid , s.serial# serial, l.lmode lmode ,
decode(L.LMODE,1,'No Lock',
2,'Row Share',
3,'Row Exclusive',
4,'Share',
5,'Share Row Exclusive',
6,'Exclusive','NONE') lmode_desc, l.type type ,
decode(l.type,
'BL','Buffer hash table instance lock',
'CF',' Control file schema global enqueue lock',
'CI','Cross-instance function invocation instance lock',
'CS','Control file schema global enqueue lock',
'CU','Cursor bind lock',
'DF','Data file instance lock',
'DL','Direct loader parallel index create',
'DM','Mount/startup db primary/secondary instance lock',
'DR','Distributed recovery process lock',
'DX','Distributed transaction entry lock',
'FI','SGA open-file information lock',
'FS','File set lock',
'HW','Space management operations on a specific segment lock',
'IN','Instance number lock',
'IR','Instance recovery serialization global enqueue lock',
'IS','Instance state lock',
'IV','Library cache invalidation instance lock',
'JQ','Job queue lock',
'KK','Thread kick lock',
'MB','Master buffer hash table instance lock',
'MM','Mount definition gloabal enqueue lock',
'MR','Media recovery lock',
'PF','Password file lock',
'PI','Parallel operation lock',
'PR','Process startup lock',
'PS','Parallel operation lock',
'RE','USE_ROW_ENQUEUE enforcement lock',
'RT','Redo thread global enqueue lock',
'RW','Row wait enqueue lock',
'SC','System commit number instance lock',
'SH','System commit number high water mark enqueue lock',
'SM','SMON lock',
'SN','Sequence number instance lock',
'SQ','Sequence number enqueue lock',
'SS','Sort segment lock',
'ST','Space transaction enqueue lock',
'SV','Sequence number value lock',
'TA','Generic enqueue lock',
'TD','DDL enqueue lock',
'TE','Extend-segment enqueue lock',
'TM','DML enqueue lock',
'TT','Temporary table enqueue lock',
'TX','Transaction enqueue lock',
'UL','User supplied lock',
'UN','User name lock',
'US','Undo segment DDL lock',
'WL','Being-written redo log instance lock',
'WS','Write-atomic-log-switch global enqueue lock') type_desc ,
request , block
FROM v$lock l, v$session s
WHERE s.sid = l.sid
AND l.type <> 'MR'
AND s.type <> 'BACKGROUND'
ORDER BY username;

