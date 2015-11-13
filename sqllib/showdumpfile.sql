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
  select name,value from v$parameter where name in ('background_dump_dest','core_dump_dest','user_dump_dest','audit_file_dest');
BEGIN
 FOR c in cfs LOOP
 DBMS_OUTPUT.PUT_LINE(c.name||'='||c.value);
 END LOOP;
END;
/
spool off;
exit;
