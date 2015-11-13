/*
子表上的外键对应列没有索引
删除父表行中记录时，会导致子表全表锁住，不利于并发，影响性能。
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

DEFINE spfile=&1

spool &spfile;
DECLARE
CURSOR findexes IS
select owner,table_name, constraint_name
      ,cname1
       || nvl2(cname2, ', ' || cname2, null)
       || nvl2(cname3, ', ' || cname3, null)
       || nvl2(cname4, ', ' || cname4, null)
       || nvl2(cname5, ', ' || cname5, null)
       || nvl2(cname6, ', ' || cname6, null)
       || nvl2(cname7, ', ' || cname7, null)
       || nvl2(cname8, ', ' || cname8, null) as cols
from (
select a.owner,b.table_name, b.constraint_name
      ,max(decode(a.position, 1, a.column_name, null)) as cname1
      ,max(decode(a.position, 2, a.column_name, null)) as cname2
      ,max(decode(a.position, 3, a.column_name, null)) as cname3
      ,max(decode(a.position, 4, a.column_name, null)) as cname4
      ,max(decode(a.position, 5, a.column_name, null)) as cname5
      ,max(decode(a.position, 6, a.column_name, null)) as cname6
      ,max(decode(a.position, 7, a.column_name, null)) as cname7
      ,max(decode(a.position, 8, a.column_name, null)) as cname8
      ,count(*) as col_cnt
from dba_cons_columns  a,
      dba_constraints b
where a.constraint_name = b.constraint_name
and   b.constraint_type = 'R'
and a.owner = b.owner
and a.owner NOT IN
       ('SYSTEM', 'SYS', 'OLAPSYS', 'SI_INFORMTN_SCHEMA', 'MGMT_VIEW',
        'ORDPLUGINS', 'TSMSYS', 'XDB', 'SYSMAN', 'WMSYS', 'SCOTT', 'DBSNMP',
        'DMSYS', 'DIP', 'OUTLN', 'EXFSYS', 'ANONYMOUS', 'CTXSYS', 'ORDSYS',
        'MDSYS', 'MDDATA')
group by b.table_name, b.constraint_name,a.owner
) cons
where col_cnt > all
      (
      select count(*)
      from dba_ind_columns i
      where i.table_name = cons.table_name
      and   i.column_name in(cname1, cname2, cname3, cname4, cname5, cname6, cname7, cname8)
      and   i.column_position <= cons.col_cnt
      and i.index_owner=cons.owner
      group by i.index_name
      );

BEGIN
   FOR i IN findexes LOOP
       DBMS_OUTPUT.PUT_LINE('owner="'||i.owner||'" tablename="'||i.table_name||'" constraintname="'||i.constraint_name||'" cols="'||i.cols||'"');
   END LOOP;
END;
/
spool off;
exit;
