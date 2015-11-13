/*
行数大于 1亿，索引BLEVEL值检查；
期望值小于4；
blevel：b-tree index's branch level
*/
SET LINE 200;
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
DEFINE v_blevel=&2

spool &spfile;
DECLARE
CURSOR indexes IS
   select index_name,index_type,TABLE_NAME,table_owner,blevel
   from SYS.DBA_INDEXES
   where OWNER  not in (SELECT USERNAME FROM DBA_USERS U WHERE U.ACCOUNT_STATUS NOT IN ( 'OPEN'))
   AND num_rows <100000000 and blevel > &v_blevel;

BEGIN
   FOR i IN indexes LOOP
       DBMS_OUTPUT.PUT_LINE('indexname="'||i.index_name||'" indextype="'||i.index_type||'" tablename="'||i.table_name||'" owner='||i.table_owner||'" blevel="'||i.blevel||'"');
   END LOOP;
END;
/
spool off;
exit;
