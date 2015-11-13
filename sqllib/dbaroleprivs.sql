/*

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
CURSOR dbas IS
select  *  from dba_role_privs
where GRANTED_ROLE='DBA'
and GRANTEE not in ('SYS','SYSTEM','SYSMAN')
and GRANTEE not in (select username from dba_users where account_status not in ('OPEN'));

BEGIN
 FOR c in dbas LOOP
 DBMS_OUTPUT.PUT_LINE('grantee="'||c.grantee||'" grantedrole="'||c.GRANTED_ROLE||'" adminoption="'||c.admin_option||'"');
 END LOOP;
END;
/
spool off;
exit;
