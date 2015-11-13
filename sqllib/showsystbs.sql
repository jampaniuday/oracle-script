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
CURSOR tb IS
select OWNER,SEGMENT_NAME
  FROM dba_segments
 where tablespace_NAME = 'SYSTEM'
   and owner not in ('DBSNMP',' CTXSYS','MDSYS','ODM','ODM_MTR','ORDPLUGINS',
'ORDSYS','OUTLN','SCOTT','WK_PROXY','WK_SYS','WMSYS','XDB',
'TRACESVR','OAS_PUBLIC','WEBSYS','LBACSYS','RMAN','PERFSTAT',
'EXFSYS','SI_INFORMTN_SCHEMA','SYS','SYSTEM')
   and owner in (select username from dba_users where account_status='OPEN');

BEGIN
 FOR c in tb LOOP
 DBMS_OUTPUT.PUT_LINE('owner="'||c.owner||'" segmentname="'||c.segment_name||'"');
 END LOOP;
END;
/
spool off;
exit;
