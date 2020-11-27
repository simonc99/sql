with totalrows as (
select sum(b.value) val1 from v$statname a, v$sysstat b
where a.statistic# = b.statistic# and
a.name in ('table scan rows gotten','table fetch by rowid')),
migrows as (
select d.value val2 from v$statname c, v$sysstat d 
where c.statistic# = d.statistic# and
c.name = 'table fetch continued row')
select round((val2/val1)*100,2) "% MIGRATED ROWS FETCHED" from totalrows, migrows;
