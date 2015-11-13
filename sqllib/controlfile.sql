/*
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
DECLARE
CURSOR cfs IS
    select name,nvl(status,'null') status from v$controlfile ;

BEGIN
 FOR c in cfs LOOP
 DBMS_OUTPUT.PUT_LINE('name="'||c.name||'" status="'||c.status||'"');
 END LOOP;
END;
/
spool off;
exit;
