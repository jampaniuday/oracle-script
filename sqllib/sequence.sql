/*
cycle_flag:Does sequence wrap around on reaching limit;
查询 sequence 使用情况；
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
CURSOR seqs IS
select * from dba_sequences where cycle_flag='N' and sequence_owner not in ('SYS','SYSTEM') and sequence_owner not in (select username from dba_users where account_status not in ('OPEN'));

BEGIN
  FOR seq IN seqs LOOP
  DBMS_OUTPUT.PUT_LINE('owner="'||seq.sequence_owner||'" name="'||seq.sequence_name||'" last_number="'||seq.last_number||'" max_value="'||seq.max_value||'"');
END LOOP;
END;
/
spool off;
exit;
