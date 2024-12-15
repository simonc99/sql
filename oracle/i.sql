/********************************************************************
 * File:	i.sql
 * Type:	SQL*Plus script
 * Author:	Tim Gorman (Evergreen Database Technologies, Inc.)
 * Date:	11-Feb-93
 *
 * Description:
 *	Script to display indexes for a table.
 *
 * Modification:
 *	TGorman 25sep99	added RULE hint to deal with nasty CBO bug
 *			where OPTIMIZER_MODE is either FIRST_ROWS
 *			or ALL_ROWS.  Essentially, if using these
 *			settings of OPTIMIZER_MODE, then queries
 *			against the DD views perform horribly because
 *			the DD tables are not ANALYZEd...
 *	TGorman 31mar04	added functionality to display partitioning
 *			information...
 ********************************************************************/
clear breaks computes
break on owner on type on uniqueness on part_type on index_name on report
set pages 100 lines 130 trimout on trimspool on verify off feedback off
undef tbl_name
col owner format a15 heading "Owner"
col type format a6 truncate heading "Type"
col part_type format a6 truncate heading "Part?"
col uniqueness format a4 heading "Unq?"
col index_name format a30 heading "Index name"
col column_name format a30 heading "Column name"
col sort0 noprint
col sort1 noprint
col sort2 noprint

spool &&tbl_name..idx
select /*+ rule */
	i.owner sort0,
	i.index_name sort1,
	c.column_position sort2,
	i.owner,
	i.index_type type,
	decode(i.uniqueness, 'UNIQUE', 'YES', 'NO') uniqueness,
	decode(i.partitioned, 'YES', p.locality, 'NO') part_type,
	i.index_name,
	c.column_name
from	all_indexes		i,
	all_part_indexes	p,
	all_ind_columns		c
where	i.table_name = upper('&&tbl_name')
and	p.owner (+) = i.owner
and	p.index_name (+) = i.index_name
and	p.table_name (+) = i.table_name
and	c.index_owner (+) = i.owner
and	c.index_name (+) = i.index_name
union
select	c.owner sort0,
	c.name sort1,
	decode(p.alignment, 'PREFIXED', -100000, 100000) + c.column_position sort2,
	c.owner,
	i.index_type type,
	decode(i.uniqueness, 'UNIQUE', 'YES', 'NO') uniqueness,
	decode(i.partitioned, 'YES', p.locality, '') part_type,
	c.name index_name,
	'*'||c.column_name column_name
from	all_indexes		i,
	all_part_indexes	p,
	all_part_key_columns	c
where	i.table_name = upper('&&tbl_name')
and	i.partitioned = 'YES'
and	p.owner (+) = i.owner
and	p.index_name (+) = i.index_name
and	p.table_name (+) = i.table_name
and	c.owner (+) = i.owner
and	c.name (+) = i.index_name
and	c.object_type (+) like 'INDEX%'
order by 1, 2, 3;
prompt
set heading off
select	distinct chr(9)||'* - indicates a partition-key column' footnote_text
from	all_indexes
where	table_name = upper('&&tbl_name')
and	partitioned = 'YES';
prompt
spool off
set verify on feedback on heading on


