/*
查询包含错误关键字的alert 日志 [前一天]
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
DEFINE errorkeys=&2

spool &spfile;
declare
CURSOR errorlist is
SELECT originating_timestamp,record_id, translate(message_text,chr(13)||chr(10),',') message_text
FROM X$DBGALERTEXT
WHERE originating_timestamp > systimestamp - 1 AND regexp_like(message_text,'(&errorkeys)');

begin
  for l in errorlist
  loop
    DBMS_OUTPUT.PUT_LINE('timestamp="'||l.originating_timestamp||'" message="'||l.message_text||'"');
  end loop;
end;
/
spool off;
exit;
