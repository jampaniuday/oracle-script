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
CURSOR cfs IS
select i.instance_name,b1.name ,b1.value
from gv$sysstat b1,gv$instance i
where b1.name in ('global cache cr block receive time','global cache cr blocks received') and b1.inst_id=i.inst_id;

BEGIN
 FOR c in cfs LOOP
 DBMS_OUTPUT.PUT_LINE('instancename="'||c.instance_name||'" name="'||c.name||'" value="'||c.value||'"');
 END LOOP;
END;
/
spool off;
exit;
