/*
查询一周没有rman 备份的表空间
*/

SET LINE 200;
SET serveroutput on size 1000000
SET echo OFF　　　　
SET feedback OFF　　
SET heading OFF　　
SET pagesize 0　　　
SET termout OFF　
SET trimout ON　　　
SET trimspool ON　　
SET verify OFF

DEFINE spfile=&1
DEFINE v_str=&2

spool &spfile;
DECLARE
CURSOR rmbks IS
   select name from v$datafile where file# in (select file# from v$datafile minus
   select file# from v$backup_datafile where completion_time >= sysdate-&&v_str) and creation_time < sysdate - &v_str;
BEGIN
  FOR rmbk in rmbks LOOP
  DBMS_OUTPUT.PUT_LINE('nobkdatafile='||rmbk.name);
  END LOOP;
END;
/
spool off;
exit;
