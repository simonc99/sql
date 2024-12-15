Set Verify Off Feedback 2 Pause Off Pagesize 66 Linesize 80 ;
Set ServerOutput On ;

DECLARE

  -- declare local variables
  nLDataSize sys.dba_data_files.bytes%TYPE ;
  nLFreeSize sys.dba_free_space.bytes%TYPE ;

  -- declare cursors
  CURSOR cGetTableSpace IS
    SELECT t.tablespace_name
    FROM   sys.dba_tablespaces  t
    ORDER  BY 1
  ;

  CURSOR cGetDataFiles 
   ( sLTablespaceName sys.dba_tablespaces.tablespace_name%TYPE ) IS
    SELECT Sum( d.bytes )
    FROM   sys.dba_data_files  d
    WHERE  d.tablespace_name = sLTableSpaceName
  ;

  CURSOR cGetFreeSpace 
   ( sLTablespaceName sys.dba_tablespaces.tablespace_name%TYPE ) IS
    SELECT Sum( f.bytes )
    FROM   sys.dba_free_space  f
    WHERE  f.tablespace_name = sLTableSpaceName
  ;

BEGIN

  Dbms_Output.Enable ( 50000 );

  -- create the column headers
  Dbms_Output.Put_Line ( 'Tablespace                     <-------- Size in'||
			 ' Bytes -------->' );
  Dbms_Output.Put_Line ( 'Name                                  Data File '||
			 '      Free Space %age Free' );
  Dbms_Output.Put_Line ( '------------------------------ ---------------- '||
			 '---------------- ---------' );

  -- get each tablespace name and then get the sizings for it
  FOR tspace IN cGetTableSpace LOOP
    
    -- get the size of the datafiles for the tablespace
    OPEN cGetDataFiles ( tspace.tablespace_name ) ;
    FETCH cGetDataFiles INTO nLDataSize ;
    IF cGetDataFiles%NOTFOUND
    OR cGetDataFiles%NOTFOUND IS NULL THEN
      nLDataSize := 0 ;
    END IF;
    CLOSE cGetDataFiles ;

    -- get the size of the free space for the tablespace
    OPEN cGetFreeSpace ( tspace.tablespace_name ) ;
    FETCH cGetFreeSpace INTO nLFreeSize ;
    IF cGetFreeSpace%NOTFOUND
    OR cGetFreeSpace%NOTFOUND IS NULL THEN
      nLFreeSize := 0 ;
    END IF;
    CLOSE cGetFreeSpace ;

    -- now display the findings
    Dbms_Output.Put_Line ( Rpad( tspace.tablespace_name, 30, ' ')||
			   ' '||
			   Lpad( To_Char( nLDataSize
					, '999,999,999,999' ), 16, ' ') ||
			   ' '||
			   Lpad( To_Char( nLFreeSize
					, '999,999,999,999' ), 16, ' ') ||
			   ' '||
                           Lpad( To_Char( Round( ( 
				 ( nLFreeSize / nLDataSize )*100 ),4 )
					, '909.9999' )
                               , 9, ' ')
			 );

  END LOOP;

END;

