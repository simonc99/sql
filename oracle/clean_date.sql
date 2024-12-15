create or replace function clean_date
        (
          dirty_date char
        ) return date is

        -- Terry Seldon 23/07/07

        -- This function takes a free format (UK) date
        -- and returns a valid oracle date
        -- or NULL if conversion not possible

        -- This assumes the standard UK order i.e. day-month-year

        -- Variables

        part1           varchar2(20);
        part2           varchar2(20);
        part3           varchar2(20);
        sep             varchar2(10);
        string_day      varchar2(20);
        string_month    varchar2(20);
        string_year     varchar2(20);
        string_date     varchar2(60);
        non_numeric     varchar2(100);
        spaces          varchar2(100);

        -- Private function to return true if at least two seperators
        -- are found in the string that match the specified seperator
        function seperator_used( test_string char, sep char ) return boolean is
                pos1 integer;
                pos2 integer;
                begin
                  pos1 := instr(test_string,sep,1,1);
                  pos2 := instr(test_string,sep,1,2);
                  if (  pos1 > 0 and
                        pos2 > (pos1 + 1) and
                        pos2 < length(test_string) )
                        then
                                return true;
                  end if;
                  return false;
                end;

        -- Private function to return the day part of a date 1-31
        -- Ensures day less than days in month
        function to_day( test_string char,
                         numeric_month integer,
                         numeric_year integer  ) return char is
                numeric_day integer;
                days_in_month integer;
                begin
                        numeric_day := to_number( substr(test_string,1,2) );
                        -- If day in the right sort of range
                        if ( numeric_day > 0 and numeric_day < 32) then
                                -- Standard days in month (default 31)
                                select decode(numeric_month,2,28,4,30,6,30,9,30,11,30,31)
                                        into days_in_month from dual;
                                -- Is this a leap year?
                                if ( numeric_month = 2 and mod(numeric_year,4) = 0) then
                                        days_in_month := 29;
                                end if;
                                -- If day just past the end of the month
                                -- they probably meant the last day in month
                                if ( numeric_day > days_in_month ) then
                                        numeric_day := days_in_month;
                                end if;
                                return ltrim(to_char(numeric_day,'09'));
                        end if;
                        return 'BAD';
                end;

        -- Private function to return a month 01-12
        function to_month( test_string char ) return char is
                numeric_month integer;
                begin
                        if ( instr(test_string,'JAN') > 0 ) then
                                return '01';
                        end if;
                        if ( instr(test_string,'FEB') > 0 ) then
                                return '02';
                        end if;
                        if ( instr(test_string,'MAR') > 0 ) then
                                return '03';
                        end if;
                        if ( instr(test_string,'APR') > 0 ) then
                                return '04';
                        end if;
                        if ( instr(test_string,'MAY') > 0 ) then
                                return '05';
                        end if;
                        if ( instr(test_string,'JUN') > 0 ) then
                                return '06';
                        end if;
                        if ( instr(test_string,'JUL') > 0 ) then
                                return '07';
                        end if;
                        if ( instr(test_string,'AUG') > 0 ) then
                                return '08';
                        end if;
                        if ( instr(test_string,'SEP') > 0 ) then
                                return '09';
                        end if;
                        if ( instr(test_string,'OCT') > 0 ) then
                                return '10';
                        end if;
                        if ( instr(test_string,'NOV') > 0 ) then
                                return '11';
                        end if;
                        if ( instr(test_string,'DEC') > 0 ) then
                                return '12';
                        end if;
                        numeric_month := to_number( test_string );
                        if ( numeric_month > 0 and numeric_month < 13) then
                                return ltrim(to_char(numeric_month,'09'));
                        end if;
                        return 'BAD';
                end;

        -- Private function to return the year part of a date 1920-2100
        function to_year( test_string char ) return char is
                numeric_year integer;
                begin
                        numeric_year := to_number( test_string );
                        if ( numeric_year < 20) then
                                numeric_year := numeric_year + 2000;
                        end if;
                        if ( numeric_year > 19 and numeric_year < 100) then
                                numeric_year := numeric_year + 1900;
                        end if;
                        if ( numeric_year > 1919 and numeric_year < 2101 ) then
                                return ltrim(to_char(numeric_year,'9999'));
                        end if;
                        return 'BAD';
                end;

--
-- MAIN FUNCTION
--

begin
        non_numeric :=  'ABCDEFGHIJKLMNOPQRSTUVWXYZ.,;-/';
        spaces :=       '                               ';
        sep := '';
        if ( seperator_used(dirty_date,' ')) then
                sep := ' ';
        end if;
        if ( seperator_used(dirty_date,'_')) then
                sep := '_';
        end if;
        if ( seperator_used(dirty_date,'-')) then
                sep := '-';
        end if;
        if ( seperator_used(dirty_date,'/')) then
                sep := '/';
        end if;

        if  ( sep = '' )
        then
                -- No seperator found so assume ddmmyyyy
                part1 := substr(dirty_date,1,2);
                part2 := substr(dirty_date,3,2);
                part3 := substr(dirty_date,5,20);
        else
                -- We have seperators - so lets use them!
                part1 := translate( upper(substr(dirty_date,1,instr(dirty_date,sep,1,1)-1)), non_numeric, spaces);
                part2 := upper( substr(dirty_date,instr(dirty_date,sep,1,1)+1,
                        instr(dirty_date,sep,1,2)-instr(dirty_date,sep,1,1)-1 ) );
                part3 := upper( substr(dirty_date,instr(dirty_date,sep,1,2)+1,
                        length(dirty_date)-instr(dirty_date,sep,1,2) ) );
        end if;

        string_year  := to_year(part3);
        string_month := to_month(part2);
        if ( string_year!='BAD' and string_month!='BAD' )
        then
                string_day   := to_day(part1,to_number(string_month),to_number(string_year));
        else
                string_day := 'BAD';
        end if;
        string_date  := string_day||string_month||string_year;
        if ( instr(string_date,'BAD') = 0 )
        then
                -- This is a good date
                return to_date(string_date,'ddmmyyyy');
        end if;
        -- Default return (bad date)
        return NULL;
exception
        when others then
                return NULL;
end;
/

