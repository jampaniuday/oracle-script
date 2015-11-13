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
CURSOR logs IS
    select l.group#,f.member,nvl(f.status,'null') status,l.bytes from v$logfile f,v$log l where f.group#=l.group#;

BEGIN
 FOR c in logs LOOP
 DBMS_OUTPUT.PUT_LINE('groupnum="'||c.group#||'" name="'||c.member
 ||'" logstatus="'||c.status
 ||'" logsize="'||c.bytes
 ||'"');
 END LOOP;
END;
/
spool off;
exit;
