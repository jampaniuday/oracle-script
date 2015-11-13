/*
max_extents :  Maximum number of extents allowed in the segment
extents     :  Number of extents allocated to the segment
next_extent :  Size in bytes of the next extent to be allocated to the segment
dba_free_space's bytes       :  Size of the extent
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
CURSOR extents IS
   SELECT
     ds.owner,ds.segment_name,partition_name,ds.tablespace_name,dfs.MAX,ds.EXTENTS,ds.max_extents,ds.next_extent
FROM
    dba_segments ds
  , (SELECT
         MAX(bytes) MAX
       , tablespace_name
     FROM
         dba_free_space
     GROUP BY
         tablespace_name
    ) dfs
WHERE ds.tablespace_name = dfs.tablespace_name(+)
  AND ds.owner NOT IN ('SYS','SYSTEM') AND ds.owner NOT IN (SELECT username FROM dba_users WHERE account_status NOT IN ('OPEN'));

BEGIN
   FOR i IN extents LOOP
       DBMS_OUTPUT.PUT_LINE('owner="'||i.owner||'" tablename="'||i.segment_name||'" partitionname="'||i.partition_name||'" tablespacename="'||i.tablespace_name||'" dfsmxextents="'||i.max||'" dsextents="'||i.extents||'" dsmxextents="'||i.max_extents||'" dsnextextent="'||i.next_extent||'"');
   END LOOP;
END;
/
spool off;
exit;
