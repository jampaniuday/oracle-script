/*
serial#:
Session serial number. Used to uniquely identify a session's objects.
Guarantees that session-level commands are applied to the correct session objects
if the session ends and another session begins with the same session ID.

单个session 占用 pga情况查询
CCB 建议 小于100M
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
DEFINE p=&2

spool &spfile;
declare
cursor sessions is
select s.sid,s.serial#,PGA_ALLOC_MEM
from v$session s,v$process p
where p.addr=s.paddr and p.PGA_ALLOC_MEM/1024/1024 > &p;

begin
  for i in sessions loop
    dbms_output.put_line('sessionid="'||i.sid||'" serialnum="'||i.serial#||'" pgamem="'||i.PGA_ALLOC_MEM||'"');
  end loop;
end;
/
spool off;
exit;
