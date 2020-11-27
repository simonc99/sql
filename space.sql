set serveroutput on verify off echo off

/*
*  Name:	space.sql
*  Author:	Ian Harrison
*  Date:	25/1/99
*
*  Parameters:	&1 the owner of the segment
*		&2 the segment name
*		&3 the segment type
*
*  Usage:	@space vmslive vms_day_17 table VMS_DATA_17
*
*  This script uses the dbms_space calls (.free_blocks and .unused_space)
*  to obtain info about a given segment (table or index).
*  Free space is defined as blocks on the freelist below the highwater mark
*  Unused space is defained as blocks above the highwater mark (i.e. they
*  have never been used.
*
*  Restrictions:	Oracle 7 only.
*/


declare
	total_blocks number;
	total_bytes number;
	unused_blocks number;
	unused_bytes number;
	last_used_extent_file_id number;
	last_used_extent_block_id number;
	last_used_block number;
	free_blocks number;
	free_bytes number;
	pic1 number;
	pic2 number;
	pic3 number;
	v_width number;
	block_size number;
	oversion varchar2(20);

	segment_owner varchar2(30) := upper('&1');
	segment_name varchar2(128) := upper('&2');
	segment_type varchar2(30) := upper('&3');

BEGIN
   /*
   * get the unused space info
   */
   sys.dbms_space.unused_space(segment_owner=>segment_owner,
		segment_name=>segment_name,
		segment_type=>segment_type,
		total_blocks=>total_blocks,
		total_bytes=>total_bytes,
		unused_blocks=>unused_blocks,
		unused_bytes=>unused_bytes,
		last_used_extent_file_id=>last_used_extent_file_id,
		last_used_extent_block_id=>last_used_extent_block_id,
		last_used_block=>last_used_block);

   /*
   * get the free space info
   */
   sys.dbms_space.free_blocks(segment_owner=>segment_owner,
		segment_name=>segment_name,
		segment_type=>segment_type,
		freelist_group_id=>0,
		free_blks=>free_blocks);
   /*
   *  claculate the db block size
   */
   block_size := total_bytes / total_blocks;

   /*
   *  now output the header info
   */
   dbms_output.put_line(chr(11)||'Segment Size Info for '||segment_type||' '||
			segment_owner||'.'||segment_name||'...'||chr(11));
   dbms_output.put_line('.                      Total blocks: '||
			to_char(total_blocks,'99,999,999,999'));
   dbms_output.put_line('.                       Total bytes: '||
			to_char(total_bytes,'99,999,999,999'));

   /*
   *  followed by the unused space info
   */
   dbms_output.put_line(chr(11)||'Unused space above HighWater mark...');
   dbms_output.put_line('.                     Unused blocks: '||
			to_char(unused_blocks,'99,999,999,999'));
   dbms_output.put_line('.                      Unused bytes: '||
			to_char(unused_bytes,'99,999,999,999'));
   /*
    * don't bother outputting these fields
    *
    *   dbms_output.put_line('.          last_used_extent_file_id: '||last_used_extent_file_id);
    *   dbms_output.put_line('.         last_used_extent_block_id: '||last_used_extent_block_id);
    *   dbms_output.put_line('.                   last_used_block: '||last_used_block);
    */

   /*
   *  now output the freespace info
   */
   dbms_output.put_line(chr(11)||'Unused space below HighWater mark...');
   dbms_output.put_line('.                       Free blocks: '||
			to_char(free_blocks,'99,999,999,999'));
   dbms_output.put_line('.                        Free bytes: '||
			to_char(round(free_blocks*block_size,0),'99,999,999,999'));

   /*
   *  now draw a picture for the hard-of-thinking (me)
   */
   v_width := 78;
   pic1 := v_width;
   pic2 := round((1 - (unused_blocks / total_blocks)) * v_width,0);
   pic3 := round((total_blocks - unused_blocks - free_blocks ) / total_blocks * v_width,0);

   dbms_output.put_line(chr(11)||'Picture key: = Segment size   + Highwater mark   . Used blocks'||chr(11));

   dbms_output.put_line(rpad(' ',pic1,'='));
   /*
   *  make sure that we don't output a blank line
   *  always output at least one character
   */
   IF pic2 < 1 THEN
      dbms_output.put_line('+');
   ELSE
      dbms_output.put_line(rpad(' ',pic2,'+'));
   END IF;
   IF pic3 < 1 THEN
      dbms_output.put_line('.');
   ELSE
      dbms_output.put_line(rpad(' ',pic3,'.'));
   END IF;


END;
/


