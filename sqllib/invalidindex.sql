/*
查询无效索引,包括分区索引，子分区索引
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
CURSOR indexes IS
SELECT owner,index_name,table_name,status
      FROM   dba_indexes
      WHERE  status<>'VALID'
      AND    partitioned <> 'YES'
      UNION ALL
SELECT index_owner owner,index_name,PARTITION_NAME table_name,status
      FROM   dba_ind_partitions
      WHERE  status<>'USABLE'
      UNION ALL
SELECT index_owner owner,index_name,PARTITION_NAME table_name,status
      FROM   dba_ind_subpartitions
      WHERE  status<>'USABLE';

BEGIN
  FOR j IN indexes LOOP
  DBMS_OUTPUT.PUT_LINE('owner="'||j.owner||'" indexname="'||j.index_name||'" tablename="'||j.table_name||'" status="'||j.status||'"');
  END LOOP;
END;
/
spool off;
exit;
