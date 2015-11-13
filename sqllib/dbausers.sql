/*
查询数据库 用户属性
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

spool &spfile;
DECLARE
CURSOR users IS
select username,USER_ID userid,account_status,to_char(expiry_date,'yyyyddmm') expirydate,to_char(lock_date,'yyyymmdd') lockdate ,default_tablespace,profile
from dba_users;

BEGIN
 FOR c in users LOOP
 DBMS_OUTPUT.PUT_LINE('username="'||c.username||'" userid="'||c.userid||'" status="'
 ||c.account_status||'" expirydate="'||c.expirydate||'" lockdate="'||c.lockdate
 ||'" defaulttablespace="'||c.default_tablespace||'" profile="'||c.profile||'"');
 END LOOP;
END;
/
spool off;
exit;
