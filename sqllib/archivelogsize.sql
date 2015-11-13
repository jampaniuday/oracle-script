/*
查询归档日志，一定时间区间内产生的归档大小
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


define spfile=&1;
define daynum=&2;

DECLARE
arch v$instance.archiver%TYPE;

CURSOR archlist IS
SELECT to_char(completion_time,'yyyymmdd') completetime,round(sum( BLOCKS*block_size)/1024) lsize
FROM v$archived_log WHERE completion_time > SYSDATE -&daynum AND thread# IN (SELECT thread#
FROM v$instance) AND dest_id=1 GROUP BY to_char(completion_time,'yyyymmdd')
ORDER BY to_char(completion_time,'yyyymmdd');

spool &spfile;
BEGIN
SELECT archiver INTO arch FROM v$instance;
IF ( arch = 'STOPPED') THEN
   dbms_output.put_line('timestamp="'||to_char(SYSDATE,'yyyymmdd')||'" usedspace="0"');
   ELSE
    FOR  A IN archlist
    loop
       dbms_output.put_line('timestamp="'||A.completetime||'" usedspace='||A.lsize||'"');
    END loop;
   END IF;
END;
/
spool OFF;
exit;
