/*
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
CURSOR dbfs IS
SELECT f.tablespace_name tbsname,f.file_name dbfname,f.bytes,f.status dbfstatus,f.autoextensible ,d.status tbsstatus
         FROM dba_data_files f ,dba_tablespaces d
         where  f.tablespace_name = d.tablespace_name
union all
SELECT f.tablespace_name tbsname,f.file_name dbfname,f.bytes,f.status dbfstatus,f.autoextensible ,d.status tbsstatus
         FROM dba_temp_files f ,dba_tablespaces d
         where  f.tablespace_name = d.tablespace_name;

BEGIN
 FOR c in dbfs LOOP
 DBMS_OUTPUT.PUT_LINE('tablespacename="'||c.tbsname
 ||'" dbfilename="'||c.dbfname||'" dbsize="'||c.bytes
 ||'" dbfstatus="'||c.dbfstatus||'" tbsstatus="'||c.tbsstatus
 ||'" autoextents="'||c.autoextensible||'"');
 END LOOP;
END;
/
spool off;
exit;
