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
CURSOR asmdisks IS
    select group_number,disk_number,name,total_mb,free_mb,path,state from v$asm_disk;

BEGIN
 FOR c in asmdisks LOOP
 DBMS_OUTPUT.PUT_LINE('groupnumber="'||c.group_number
 ||'" disknumber="'||c.disk_number
 ||'" name="'||c.name
 ||'" totalmb="'||c.total_mb
 ||'" freemb="'||c.free_mb
 ||'" path="'||c.path
 ||'" status="'||c.state
 ||'"');
 END LOOP;
END;
/
spool off;
exit;
