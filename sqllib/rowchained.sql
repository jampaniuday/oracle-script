/*
chain_cnt:
Number of rows in the table that are chained from one data block to another,
or which have migrated to a new block, requiring a link to preserve the old ROWID
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
DEFINE chainsnum=&2

spool &spfile;
set serveroutput on;

DECLARE
CURSOR chains IS
SELECT
    table_owner,table_name,num_rows,ROUND((chain_cnt/num_rows)*100, 2) chainp,avg_row_len
FROM
    (select
         owner as table_owner
       , table_name
       , chain_cnt
       , num_rows
       , avg_row_len
     from
         sys.dba_tables
     where
          chain_cnt > 0
       and num_rows > 0
       and owner != 'SYS')
WHERE
    (chain_cnt/num_rows)*100 > &chainsnum
UNION ALL
SELECT
    table_owner,table_name,num_rows,ROUND((chain_cnt/num_rows)*100, 2) chainp,avg_row_len
FROM
    (select
         table_owner
       , table_name
       , chain_cnt
       , num_rows
       , avg_row_len
     from
         sys.dba_tab_partitions
     where
       chain_cnt > 0
       and num_rows > 0
       and table_owner != 'SYS') b
WHERE
    (chain_cnt/num_rows)*100 > &chainsnum;

begin
  for i in chains
  loop
    dbms_output.put_line('owner="'||i.table_owner||'" talbename="'||i.table_name||'" numrows="'||i.num_rows||'" avgrowlen="'||i.avg_row_len||'" chainpercent="'||i.chainp||'"');
  end loop;
end;
/
spool off;
exit;
