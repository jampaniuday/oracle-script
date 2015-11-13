/*
  show oracle database verison
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
CURSOR vs IS
select product,version from PRODUCT_COMPONENT_VERSION;

BEGIN
 FOR c in vs LOOP
 DBMS_OUTPUT.PUT_LINE('componetname="'||c.product||'" version="'||c.version||'"');
 END LOOP;
END;
/
spool off;
exit;
