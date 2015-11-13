/*
数据库资源限制检查，resource_limit
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

spool &spfile
DECLARE
CURSOR res IS
  select RESOURCE_NAME, CURRENT_UTILIZATION ,MAX_UTILIZATION ,initial_allocation INITIAL_ALLOCATION,LIMIT_VALUE
  from v$resource_limit;

BEGIN
  FOR s IN res LOOP
     DBMS_OUTPUT.PUT_LINE('resourcename="'||s.resource_name||'" currentutilization="'||s.current_utilization||'" maxutilization="'||s.max_utilization||'" initialallocation="'||replace(s.initial_allocation,' ','')||'" limit_value="'||replace(s.limit_value,' ','')||'"');
  END LOOP;
END;
/
spool off;
exit;
