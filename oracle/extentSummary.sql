def ownr	= &&1
def segt 	= &&2

col ownr form	   a8 head 'Owner'		just c
col name form     a28 head 'Segment Name'	just c
col type form      a8 head 'Type'		just c trunc
col hfil form   9,990 head 'Header|File'	just c
col hblk form  99,990 head 'Header|Block'	just c
col exts form   9,990 head 'Extents'		just c
col blks form 999,990 head 'Blocks'		just c

break on ownr skip 1

select
	owner		ownr,
	segment_name	name,
	segment_type	type,
	header_file	hfil,
	header_block	hblk,
	extents		exts,
	blocks		blks
from
	dba_segments
where
	owner like upper('&ownr')
and
	segment_name like upper ('&segt')

/

undef ownr
undef segt
