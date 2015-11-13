/*
request_failures:
Number of times that no memory was found to satisfy a request (that is, the number of times the error ORA-04031 occurred)
ABORTED_REQUESTS:
Number of requests that signalled an ORA-04031 error without flushing objects
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
declare
cursor sharers is
SELECT  request_failures,ABORTED_REQUESTS FROM v$shared_pool_reserved;

begin
  for i in sharers loop
    dbms_output.put_line('requestfailures="'||i.request_failures||'" abortedrequests="'||i.ABORTED_REQUESTS||'"');
  end loop;
end;
/
spool off;
exit;
