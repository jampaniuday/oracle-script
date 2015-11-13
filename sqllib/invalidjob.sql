/*
查询无效对象
*/
SET LINE 200;
set serveroutput on size 1000000
SET echo OFF　　　　
SET feedback OFF　　
SET heading OFF　　
SET pagesize 0　　　
SET termout OFF　
SET trimout ON　　　
SET trimspool ON　　

DEFINE spfile=&1

spool &spfile;
DECLARE
CURSOR jobs IS
select * from dba_jobs ;

BEGIN
  FOR job IN jobs LOOP
  DBMS_OUTPUT.PUT_LINE('jobid="'||job.job||'" user="'||job.log_user||'" broken="'||job.broken||'" failures="'||job.failures||'"');
  END LOOP;
END;
/
spool off;
exit;
