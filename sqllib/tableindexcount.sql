/*
单表上索引关联表列数量过多；联合索引,关联的表列数量;
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
DEFINE counts=&2

spool &spfile
DECLARE
CURSOR indexes IS
SELECT * FROM
(SELECT    A.index_owner, A.table_name, A.index_name,
            count(*) column_count
  FROM      dba_ind_columns A
  WHERE     A.index_owner NOT IN ('SYSTEM', 'SYS')
  AND  A.index_owner NOT IN (SELECT username FROM dba_users WHERE account_status NOT IN ('OPEN'))
  GROUP BY  A.index_owner, A.table_name, A.index_name)
  WHERE column_count > &counts;
BEGIN
  FOR i IN indexes loop
   dbms_output.put_line('owner="'||i.index_owner||'" tablename="'||i.table_name||'" indexname="'
   ||i.index_name||'" colcount="'||i.column_count||'"');
  END loop;
END;
/
spool off;
exit;
