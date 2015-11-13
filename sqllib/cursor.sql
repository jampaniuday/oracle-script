/*
数据库游标检查;
查询游标打开数量与可打开游标数量的比率
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

COL open_cursors FOR a20
COL session_cached_cursors FOR a20
spool &spfile;
DECLARE
CURSOR curs IS
select sid,open_cursors,session_cached_cursors,cursors
from (SELECT sid,(select value from v$parameter where name ='session_cached_cursors') session_cached_cursors,cursors,
    (select value max_cursor_limit from v$parameter where name='open_cursors' ) open_cursors
    from (select sid,count(*) cursors
    from v$open_cursor group by sid order by 2 desc));
BEGIN
 FOR cur in curs LOOP
 DBMS_OUTPUT.PUT_LINE('sid="'||cur.sid||'" opencursor="'||cur.open_cursors||'" sessioncachedcursors="'||cur.session_cached_cursors||'" usedcursors="'||cur.cursors||'"');
 END LOOP;
END;
/
spool off;
exit;
