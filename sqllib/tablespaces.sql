/*
查询表空间的使用情况
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
SELECT t.*,A.SEGMENT_SPACE_MANAGEMENT FROM DBA_TABLESPACES A,
(SELECT D.TABLESPACE_NAME,
       SPACE "SUM_SPACE",
       BLOCKS "SUM_BLOCKS",
       SPACE - NVL (FREE_SPACE, 0)  "USED_SPACE",
       ROUND ( (1 - NVL (FREE_SPACE, 0) / SPACE) * 100, 2)  "USED_RATE",
       FREE_SPACE  "FREE_SPACE"
  FROM (  SELECT TABLESPACE_NAME,
                 ROUND (SUM (BYTES) / (1024 * 1024), 2) SPACE,
                 SUM (BLOCKS) BLOCKS
            FROM DBA_DATA_FILES
        GROUP BY TABLESPACE_NAME) D,
       (  SELECT TABLESPACE_NAME,
                 ROUND (SUM (BYTES) / (1024 * 1024), 2) FREE_SPACE
            FROM DBA_FREE_SPACE
        GROUP BY TABLESPACE_NAME) F
 WHERE D.TABLESPACE_NAME = F.TABLESPACE_NAME(+)
UNION ALL
SELECT D.TABLESPACE_NAME,
       SPACE  "SUM_SPACE",
       BLOCKS SUM_BLOCKS,
       USED_SPACE  "USED_SPACE",
       ROUND (NVL (USED_SPACE, 0) / SPACE * 100, 2)  "USED_RATE",
       NVL (FREE_SPACE, 0)  "FREE_SPACE"
FROM (  SELECT TABLESPACE_NAME,
                 ROUND (SUM (BYTES) / (1024 * 1024), 2) SPACE,
                 SUM (BLOCKS) BLOCKS
            FROM DBA_TEMP_FILES
        GROUP BY TABLESPACE_NAME) D,
       (  SELECT TABLESPACE_NAME,
                 ROUND (SUM (BYTES_USED) / (1024 * 1024), 2) USED_SPACE,
                 ROUND (SUM (BYTES_FREE) / (1024 * 1024), 2) FREE_SPACE
            FROM V$TEMP_SPACE_HEADER
        GROUP BY TABLESPACE_NAME) F
WHERE D.TABLESPACE_NAME = F.TABLESPACE_NAME(+)) T
WHERE T.tablespace_name = a.tablespace_name ;

BEGIN
 FOR c in tb LOOP
   DBMS_OUTPUT.PUT_LINE('tablespacename="'||c.tablespace_name||'" sumspace="'
   ||c.SUM_SPACE||'" usedspace="'||c.USED_SPACE||'" usedrate="'||c.USED_RATE
   ||'" freespace="'||c.FREE_SPACE
   ||'" segmentmanagement="'||c.segment_space_management||'"');
 END LOOP;
END;
/
spool off;
exit;
