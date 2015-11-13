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
DEFINE bigtable=&2

spool &spfile;
DECLARE
CURSOR tb IS
select owner,segment_name,bytes from dba_segments where segment_type='TABLE'
and segment_type !='TABLE PARTITION'
and owner not in (select username from dba_users where account_status ='OPEN'）
and owner not in ('SYS','SYSTEM','SYSMAN'))
and bytes > &bigtable*1024*1024*1024;

BEGIN
 FOR c in tb LOOP
 DBMS_OUTPUT.PUT_LINE('owner="'||c.owner||'" bigtable="'||c.segment_name||'bytes="'||c.bytes||'"');
 END LOOP;
END;
/
spool off;
exit;
