set echo off verify off lines 132 pages 4000

col username format a12
col object_name format a32
col sess format a12
col timer for a9 head HHH:MM:SS
col program for a32 trunc

break on username skip page on sess on program

accept locktime prompt "Enter minimum locktime in seconds [5]: " default 5


select
       s.username,
       s.sid||','||s.serial# SESS,
       lpad(replace(to_char(trunc(l.ctime/3600),'909')||':'||
               to_char(trunc(mod(l.ctime,3600)/60),'09')||':'||
               to_char(mod(l.ctime,60),'09'),' ',''),9) TIMER,
       decode(l.lmode,1,NULL,2,'Row Share',3,'Row Excl',4,'Share',5,'Sh Row Ex',6,'Exclusive',NULL) held,
       decode(l.request,1,NULL,2,'Row Share',3,'Row Excl',4,'Share',5,'Sh Row Ex',6,'Exclusive',NULL) request,
       decode(o.name,NULL,' Rollback',o.name) name,
       s.program
  from v$lock l, v$session s, sys.obj$ o
 where l.type in ('TM','TX') and o.name is not null and o.name != 'MESSAGE_LOG'
   and l.sid = s.sid
   and l.id1=o.obj# (+)
   and l.ctime>&locktime
--  order by l.id1,l.id2,timer desc
   order by s.username, timer
/
