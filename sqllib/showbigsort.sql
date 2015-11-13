/*
查询没有做分区的，且超过10g的表
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
DEFINE bigsort=&2

spool &spfile;
declare
CURSOR tb IS
select VS.USERname,sl.sql_text,vs.blocks from v$sql sl,v$sort_usage vs
where sl.hash_value=vs.sqlhash
and vs.blocks>&bigsort*1024*1024/(select value from v$parameter where name = 'db_block_size');

BEGIN
 FOR c in tb LOOP
 DBMS_OUTPUT.PUT_LINE('owner="'||c.username||'" sqlcontent="'||c.sql_text||'" usedblocks="'||c.blocks||'"');
 END LOOP;
END;
/
spool off;
exit;
