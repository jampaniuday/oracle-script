/*
fixedsize
variablesize
dbbuffer
redobuffer
*/

SET LINE 200
SET SERVEROUTPUT ON
SET echo OFF
SET feedback OFF
SET heading OFF
SET pagesize 0
SET termout OFF
SET trimout ON　　　
SET trimspool ON　　
SET verify OFF

DEFINE spfile=&1

spool &spfile;
declare
cursor keys is
select name,value from v$sga;

begin
  for i in keys loop
    dbms_output.put_line('name="'||i.name||'" value="'||i.value||'"');
  end loop;
end;
/
spool off;
exit;
