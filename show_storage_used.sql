set pages 4000 lines 110 trimspool on trimout on
col tablespace_name heading "TABLESPACE|NAME" for a25
col segment_type heading "SEGMENT|TYPE"
col NUM_SEGS heading "NUMBER OF|SEGMENTS"
col MB heading "ALLOCATED|MB"
col OWNER heading "SEGMENT|OWNER"
break on tablespace_name skip 1 page on owner
compute sum label TOTAL of MB on tablespace_name
select tablespace_name, owner, segment_type, count(*) NUM_SEGS, round(sum(bytes)/1024/1024) MB from dba_segments
where owner not in ('SYS','SYSTEM','DBSNMP','DMSYS','EXFSYS','MDSYS','OLAPSYS',
'ORDPLUGINS','ORDSYS','PERFSTAT','WKSYS','WMSYS','XDB')
and tablespace_name not in ('SYSTEM','SYSAUX')
group by tablespace_name, owner, segment_type
order by tablespace_name, owner, segment_type
/
