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


define spfile=&1;
define keys=&2;

spool &spfile;
DECLARE
CURSOR pars IS
select name,value,ISDEFAULT from v$parameter where lower(name) in
(
'cursor_sharing',
'max_dump_file_size',
'sga_target',
'cpu_count',
'parallel_max_servers',
'spfile',
'instance_name',
'db_files',
'db_cache_size',
'shared_pool_size',
'large_pool_size',
'sga_max_size',
'processes',
'fast_start_mttr_target',
'backup_tape_io_slaves',
'log_buffer',
'pga_aggregate_target');

BEGIN
 FOR c in pars LOOP
 DBMS_OUTPUT.PUT_LINE('name="'||c.name||'" value="'||c.value||'" isdefault="'||i.ISDEFAULT||'"');
 END LOOP;
END;
/
spool off;
exit;
