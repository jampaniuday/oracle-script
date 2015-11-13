/*
对表有any，drop，delete操作权限的非系统用户。
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
CURSOR privusers IS
select * from dba_sys_privs
where GRANTEE not in ('DBA','SYS','SYSTEM','SYSMAN','RESOURCE')
and grantee in ( select username from dba_users where account_status='OPEN')
and (PRIVILEGE like '%ANY%' or PRIVILEGE like 'DROP%' or PRIVILEGE like 'DELETE%')
and PRIVILEGE not like 'SELECT ANY DICTIONARY'
order by GRANTEE;
BEGIN
   FOR i IN privusers LOOP
       DBMS_OUTPUT.PUT_LINE('grantee="'||i.grantee||'" privilege="'||i.privilege||'" adminoption="'||i.admin_option||'"');
   END LOOP;
END;
/
spool off;
exit;
