/*
degree:
Number of threads per instance for scanning the index
CCB recommended not greater 1
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
DEFINE degreenum=&2

spool &spfile
declare
CURSOR degree IS
SELECT  owner,table_name,index_name,degree FROM   dba_indexes
WHERE   owner NOT IN (select username from dba_users where ACCOUNT_STATUS not in ('OPEN'))
and degree > &degreenum;

BEGIN
  FOR i IN degree LOOP
    dbms_output.put_line('indexname='||i.index_name||'" degree="'||i.degree||'"');
  END loop;
END;
/
spool off;
exit;
