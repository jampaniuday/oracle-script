/*
查询七天内 临时表空间最大利用率
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
maxused dba_hist_tbspc_space_usage.tablespace_usedsize%TYPE;
tbspc dba_temp_files.bytes%TYPE;

BEGIN
  SELECT MAX(tablespace_usedsize)
  INTO maxused
  FROM dba_hist_tbspc_space_usage A, v$tablespace b,dba_hist_snapshot c
  WHERE A.tablespace_id = b.ts#
  AND c.snap_id = A.snap_id AND b.NAME LIKE '%TEMP%'
  AND c.end_interval_time > SYSDATE - 7 ;

  SELECT sum(bytes) INTO tbspc FROM dba_temp_files GROUP BY tablespace_name;

  dbms_output.put_line('name="TEMP" total="'||tbspc||'" maxusedofweek="'||maxused||'"');
END;
/
spool off;
exit;
