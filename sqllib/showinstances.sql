/*
show database instances
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
CURSOR instances IS
  select instance_number,instance_name,version,host_name,startup_time,ARCHIVER,
  database_status,active_state from v$instance;

BEGIN
FOR instance IN instances LOOP
  DBMS_OUTPUT.PUT_LINE('instancenum="'||instance.instance_number
  ||'" instancename="'|| instance.instance_name
  ||'" databasestatus="'||instance.database_status
  ||'" archiver="'||instance.ARCHIVER
  ||'" version="'||instance.version
  ||'" uptime="'||round(sysdate - instance.startup_time)
  ||'"');
END LOOP;
END;
/
spool off;
exit;
