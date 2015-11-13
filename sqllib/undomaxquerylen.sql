/*
查询undo表空间的maxquerylen,nospaceerrcnt属性；
maxquerlen :
Identifies the length of the longest query (in seconds) executed in the instance during the period.
You can use this statistic to estimate the proper setting of the UNDO_RETENTION initialization parameter.
The length of a query is measured from the cursor open time to the last fetch/execute time of the cursor.
Only the length of those cursors that have been fetched/executed during the period are reflected in the view.

nospaceerrcnt:
Identifies the number of times space was requested in the undo tablespace and there was no free space available.
That is, all of the space in the undo tablespace was in use by active transactions.
The corrective action is to add more space to the undo tablespace.
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


spool &spfile
DECLARE
CURSOR maxquery IS
SELECT maxquerylen,nospaceerrcnt FROM v$undostat WHERE maxquerylen = (SELECT MAX(maxquerylen) FROM v$undostat);

BEGIN
  FOR m IN maxquery loop
  dbms_output.put_line('undomaxquerylen="'||m.maxquerylen||'" nospaceerrcnt="'||m.nospaceerrcnt||'"');
  END loop;
END;
/
spool off;
exit;
