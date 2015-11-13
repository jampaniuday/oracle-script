/*
查询长时间运行的sql，默认1小时；
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
DEFINE longtime=&2

spool &spfile
DECLARE
CURSOR longsqls IS
  select distinct l.sql_address,l.username,l.opname
  from v$session_longops l,dba_users u
  where l.username=u.username and u.account_status='OPEN' and l.elapsed_seconds > > &longtime;

BEGIN
  FOR sqls IN longsqls LOOP
  DBMS_OUTPUT.PUT_LINE('optname="'||sqls.opname||'" username='||sqls.username||'" sqladdress="'||sqls.sql_address||'"');
END LOOP;
END;
/
spool off;
exit;
