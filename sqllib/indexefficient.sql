/*
索引效率低：查询 行数大于500000，distinct值少且分布平均，无法筛选出20％的记录；
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

DEFINE spfile=&1
DEFINE filter=&2

spool &spfile
DECLARE
CURSOR indexes IS
SELECT owner ,table_name,index_name,num_rows,distinct_keys ,round(distinct_keys / (num_rows+1)*100,3) selection
FROM dba_indexes
WHERE owner NOT IN ('SYSTEM', 'SYS')
      AND owner NOT IN (SELECT username FROM dba_users WHERE account_status NOT IN ('OPEN'))
      AND  num_rows > 500000 and selection < &filter;
BEGIN
  FOR i IN indexes loop
   dbms_output.put_line('owner="'||i.owner||'" tablename="'||i.table_name||'" indexname="'
   ||i.index_name||'" numrows="'||i.num_rows||'" distinctkeys="'||i.distinct_keys||'" selection="'||i.selection||'"');
  END loop;
END;
/
spool off;
exit;
