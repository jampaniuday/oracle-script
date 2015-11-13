/*
pga 使用情况查询
*/

SET LINE 200;
SET serveroutput on size 1000000
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
CURSOR pgas IS
  select round((nowpga.value) / 1024 / 1024,2) valuenow,
       round(setpga.VALUE / 1024 / 1024,2) valueset,
       round(maxpga.value / 1024 / 1024,2) valuemax
  from v$pgastat nowpga, v$pgastat setpga, v$pgastat maxpga
 where nowpga.name = 'total PGA inuse'
   and setpga.NAME = 'aggregate PGA target parameter'
   and maxpga.name = 'maximum PGA allocated';

BEGIN
FOR pga IN pgas LOOP
  DBMS_OUTPUT.PUT_LINE('nowsize="'||pga.valuenow||'" '
    ||'defaultsize="'||pga.valueset||'" '||'maxsize="'
    ||pga.valuemax||'"');
END LOOP;
END;
/
spool off;
exit;
