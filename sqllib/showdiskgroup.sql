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
CURSOR asmgroups IS
    select group_number,name,state,total_mb,free_mb,compatibility,database_compatibility,allocation_unit_size from v$asm_diskgroup;

BEGIN
 FOR c in asmgroups LOOP
 DBMS_OUTPUT.PUT_LINE('groupnumber="'||c.group_number
 ||'" name="'||c.name
 ||'" totalmb="'||c.total_mb
 ||'" freemb="'||c.free_mb
 ||'" status="'||c.state
 ||'" comrdbms="'||c.database_compatibility
 ||'" comasm="'||c.compatibility
 ||'" auts="'||c.auts
 ||'"');
 END LOOP;
END;
/
spool off;
exit;
