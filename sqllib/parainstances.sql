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

define spfile=&1;

spool &spfile;
DECLARE
CURSOR instances IS
select instance_name,name,value
from gv$parameter a,gv$instance b
where name in ('instance_groups','parallel_instance_group','global cache cr block receive time','global cache cr blocks received') and a.INST_ID=b.INST_ID;

BEGIN
    FOR  A IN instances
    loop
       dbms_output.put_line('instancename="'||A.instance_name||'" name='||A.name||'" value="'||A.value||'"');
    END loop;
END;
/
spool OFF;
exit
