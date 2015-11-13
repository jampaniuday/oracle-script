/*
查询数据库中的无效对象
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

spool &spfile;
DECLARE
CURSOR invobjs IS
  SELECT o.owner, o.object_type, o.object_name, o.status
  from dba_objects o,dba_users u
  where o.owner=u.username and u.account_status='OPEN' and o.status !='VALID'
  order by OWNER,OBJECT_TYPE;

BEGIN
FOR obj IN invobjs LOOP
  DBMS_OUTPUT.PUT_LINE('owner="'||obj.owner||'" '
    ||'object_type="'||obj.object_type||'" '||'object_name="'
    ||obj.object_name||'" '||'status="'||obj.status||'"');
END LOOP;
END;
/
spool off;
exit;
