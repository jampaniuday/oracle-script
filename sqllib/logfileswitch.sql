/*
  列出当天日志切换频率，计算单位 次/小时
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
CURSOR logswitch IS
SELECT to_char(first_time,'yyyymmddhh24') TIMESTAMP,count(*) num FROM v$log_history h1 WHERE  to_char(h1.first_time,'yyyy-mm-dd')=to_char(SYSDATE,'yyyy-mm-dd') GROUP BY to_char(first_time,'yyyymmddhh24');

BEGIN
 FOR l IN logswitch loop
 dbms_output.put_line('logswitchtime="'||l.timestamp||'" count="'||l.num||'"');
 END loop;
END;
/
spool off;
exit;
