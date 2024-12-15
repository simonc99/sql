/*
 * Need ALTER SYSTEM and ALTER SESSION explicitly granted to
 * the owner of this procedure
 *
 */

create or replace procedure full_scan_big_table (p_dbmrc in number)
as
	l_cnt number;
begin
	execute immediate 
		'alter tablespace users offline';

	execute immediate
		'alter tablespace users online';

	execute immediate
		'alter session set db_file_multiblock_read_count=' || p_dbmrc;

	execute immediate
		'alter session set events
		''10046 trace name context forever, level 12''';

	execute immediate 
		'select /*+ FULL(bt_mbrc_'||p_dbmrc||') */ count(*)
		from big_table bt_mbrc_'||p_dbmrc
		into l_cnt;

	execute immediate
		'alter session set events
		''10046 trace name context off''';

end;
/
