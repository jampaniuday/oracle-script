# #####################################################
# Checking DB & LISTENERS ALERTLOG FOR ERRORS
# Checking CPU, FILESYSTEM, TABLESPACES
#  When exceeding the defined THRESHOLD
# Checking BLOCKING SESSIONS ON THE DATABASE
#
#                   #   #     #
# Author:   Mahmmoud ADEL         # # # #   ###
# Created:  22-12-13        #   #   # #   #
#
# Modified: 23-12-13 Handled non exist logs 1run
#       14-05-14 Handled non existance of
#            LOG_DIR directory.
#       18-05-14 Add Filsystem monitoring.
#       19-05-14 Add CPU monitoring.
#       03-12-14 Add Tablespaces monitoring
#       08-09-15 mpstat output change in Linux 6
# ######################################################
SCRIPT_NAME="dbalarm.sh"
SRV_NAME=`uname -n`
LNXVER=`cat /etc/redhat-release | grep -o '[0-9]'|head -1`
MAIL_LIST="youremail@yourcompany.com"

    case ${MAIL_LIST} in "youremail@yourcompany.com")
     echo
     echo "####################################################"
     echo "Please EDIT line# 22 in dbalarm.sh script and change"
     echo "youremail@yourcompany.com to your E-mail address."
     echo "####################################################"
     echo
     echo "Script Terminated !"
     echo
     exit;;
    esac

# #########################
# THRESHOLDS:
# #########################
# Modify the THRESHOLDS to the value you want:

FSTHRESHOLD=98      # THRESHOLD FOR FILESYSTEM %USED [OS]
CPUTHRESHOLD=95     # THRESHOLD FOR CPU %UTILIZATION [OS]
TBSTHRESHOLD=98     # THRESHOLD FOR TABLESPACE %USED [DB]

# #########################
# Checking The FILESYSTEM:
# #########################

# Report Partitions that have 2% or less of FREE space:

df -h > /tmp/filesystem_DBA_BUNDLE.log
df -h | grep -v "^Filesystem" | awk '{print $(NF-1)" "$NF}'| while read OUTPUT
   do
    PRCUSED=`echo ${OUTPUT}|awk '{print $1}'|cut -d'%' -f1`
    FILESYS=`echo ${OUTPUT}|awk '{print $2}'`
        if [ ${PRCUSED} -ge ${FSTHRESHOLD} ]
         then
mail -s "ALARM: Filesystem [${FILESYS}] on Server [${SRV_NAME}] has reached ${PRCUSED}% of USED space" $MAIL_LIST < /tmp/filesystem_DBA_BUNDLE.log
        fi
   done

rm -f /tmp/filesystem_DBA_BUNDLE.log

# #############################
# Checking The CPU Utilization:
# #############################

# Report CPU Utilization if reach >= 95%:
OS_TYPE=`uname -s`
CPUUTLLOG=/tmp/CPULOG_DBA_BUNDLE.log

# Getting CPU utilization in last 5 seconds:
case `uname` in
        Linux ) CPU_REPORT_SECTIONS=`iostat -c 1 5 | sed -e 's/,/./g' | tr -s ' ' ';' | sed '/^$/d' | tail -1 | grep ';' -o | wc -l`
                        if [ ${CPU_REPORT_SECTIONS} -ge 6 ]; then
                           CPU_IDLE=`iostat -c 1 5 | sed -e 's/,/./g' | tr -s ' ' ';' | sed '/^$/d' | tail -1| cut -d ";" -f 7`
                        else
                           CPU_IDLE=`iostat -c 1 5 | sed -e 's/,/./g' | tr -s ' ' ';' | sed '/^$/d' | tail -1| cut -d ";" -f 6`
                        fi
        ;;
        AIX )   CPU_IDLE=`iostat -t $INTERVAL_SEC $NUM_REPORT | sed -e 's/,/./g'|tr -s ' ' ';' | tail -1 | cut -d ";" -f 6`
        ;;
        SunOS ) CPU_IDLE=`iostat -c $INTERVAL_SEC $NUM_REPORT | tail -1 | awk '{ print $4 }'`
        ;;
        HP-UX) SAR="/usr/bin/sar"
                if [ ! -x $SAR ]; then
                 echo "sar command is not supported on your environment | CPU Check ignored"; CPU_IDLE=99
                else
                 CPU_IDLE=`/usr/bin/sar 1 5 | grep Average | awk '{ print $5 }'`
                fi
        ;;
        *) echo "uname command is not supported on your environment | CPU Check ignored"; CPU_IDLE=99
        ;;
        esac

# Getting Utilized CPU (100-%IDLE):
CPU_UTL_FLOAT=`echo "scale=2; 100-($CPU_IDLE)"|bc`

# Convert the average from float number to integer:
CPU_UTL=${CPU_UTL_FLOAT%.*}

    if [ -z ${CPU_UTL} ]
     then
      CPU_UTL=1
    fi

        if [ ${CPU_UTL} -ge ${CPUTHRESHOLD} ]
     then
        echo "Top 10 Processes:"  >  /tmp/top_processes_DBA_BUNDLE.log
        echo "================"   >> /tmp/top_processes_DBA_BUNDLE.log
        echo ""           >> /tmp/top_processes_DBA_BUNDLE.log
        ps -eo pcpu,pid,user,args | sort -k 1 -r | head -11 >> /tmp/top_processes_DBA_BUNDLE.log
mail -s "ALERT: CPU Utilization on Server [${SRV_NAME}] has reached [${CPU_UTL}%]" $MAIL_LIST < /tmp/top_processes_DBA_BUNDLE.log
    fi

rm -f ${CPUUTLLOG}
rm -f /tmp/top_processes_DBA_BUNDLE.log

# #########################
# Getting ORACLE_SID:
# #########################
# Exit with sending Alert mail if No DBs are running:
INS_COUNT=$( ps -ef|grep pmon|grep -v grep|grep -v ASM|wc -l )
    if [ $INS_COUNT -eq 0 ]
     then
     echo "Reported By Script: ${SCRIPT_NAME}:" > /tmp/oracle_processes_DBA_BUNDLE.log
     echo " " >> /tmp/oracle_processes_DBA_BUNDLE.log
     echo "The following are the processes running by oracle user on server ${SRV_NAME}:" >> /tmp/oracle_processes_DBA_BUNDLE.log
     echo " " >> /tmp/oracle_processes_DBA_BUNDLE.log
     ps -ef|grep ora >> /tmp/oracle_processes_DBA_BUNDLE.log
mail -s "ALARM: No Databases Are Running on Server: $SRV_NAME !!!" $MAIL_LIST < /tmp/oracle_processes_DBA_BUNDLE.log
     rm -f /tmp/oracle_processes_DBA_BUNDLE.log
     exit
    fi

# #########################
# Setting ORACLE_SID:
# #########################
for ORACLE_SID in $( ps -ef|grep pmon|grep -v grep|grep -v ASM|awk '{print $NF}'|sed -e 's/ora_pmon_//g'|grep -v sed|grep -v "s///g" )
   do
    export ORACLE_SID

# #########################
# Getting ORACLE_HOME
# #########################
  ORA_USER=`ps -ef|grep ${ORACLE_SID}|grep pmon|grep -v grep|grep -v ASM|awk '{print $1}'|tail -1`
  USR_ORA_HOME=`grep ${ORA_USER} /etc/passwd| cut -f6 -d ':'|tail -1`

## If OS is Linux:
if [ -f /etc/oratab ]
  then
  ORATAB=/etc/oratab
  ORACLE_HOME=`grep -v '^\#' $ORATAB | grep -v '^$'| grep -i "^${ORACLE_SID}:" | perl -lpe'$_ = reverse' | cut -f3 | perl -lpe'$_ = reverse' |cut -f2 -d':'`
  export ORACLE_HOME

## If OS is Solaris:
elif [ -f /var/opt/oracle/oratab ]
  then
  ORATAB=/var/opt/oracle/oratab
  ORACLE_HOME=`grep -v '^\#' $ORATAB | grep -v '^$'| grep -i "^${ORACLE_SID}:" | perl -lpe'$_ = reverse' | cut -f3 | perl -lpe'$_ = reverse' |cut -f2 -d':'`
  export ORACLE_HOME
fi

## If oratab is not exist, or ORACLE_SID not added to oratab, find ORACLE_HOME in user's profile:
if [ -z "${ORACLE_HOME}" ]
 then
  ORACLE_HOME=`grep -h 'ORACLE_HOME=\/' $USR_ORA_HOME/.bash* $USR_ORA_HOME/.*profile | perl -lpe'$_ = reverse' |cut -f1 -d'=' | perl -lpe'$_ = reverse'|tail -1`
  export ORACLE_HOME
fi

# #########################
# Variables:
# #########################
export PATH=$PATH:${ORACLE_HOME}/bin
export LOG_DIR=${USR_ORA_HOME}/BUNDLE_Logs
mkdir -p ${LOG_DIR}
chown -R ${ORA_USER} ${LOG_DIR}
chmod -R go-rwx ${LOG_DIR}

        if [ ! -d ${LOG_DIR} ]
         then
          mkdir -p /tmp/BUNDLE_Logs
          export LOG_DIR=/tmp/BUNDLE_Logs
          chown -R ${ORA_USER} ${LOG_DIR}
          chmod -R go-rwx ${LOG_DIR}
        fi

# ########################
# Getting ORACLE_BASE:
# ########################

# Get ORACLE_BASE from user's profile if it EMPTY:

if [ -z "${ORACLE_BASE}" ]
 then
  ORACLE_BASE=`grep -h 'ORACLE_BASE=\/' $USR_ORA_HOME/.bash* $USR_ORA_HOME/.*profile | perl -lpe'$_ = reverse' |cut -f1 -d'=' | perl -lpe'$_ = reverse'|tail -1`
fi

# #########################
# Getting DB_NAME:
# #########################
VAL1=$(${ORACLE_HOME}/bin/sqlplus -S "/ as sysdba" <<EOF
set pages 0 feedback off;
prompt
SELECT name from v\$database
exit;
EOF
)
# Getting DB_NAME in Uppercase & Lowercase:
DB_NAME_UPPER=`echo $VAL1| perl -lpe'$_ = reverse' |awk '{print $1}'|perl -lpe'$_ = reverse'`
DB_NAME_LOWER=$( echo "$DB_NAME_UPPER" | tr -s  '[:upper:]' '[:lower:]' )
export DB_NAME_UPPER
export DB_NAME_LOWER

# DB_NAME is Uppercase or Lowercase?:

     if [ -d $ORACLE_HOME/diagnostics/${DB_NAME_LOWER} ]
        then
                DB_NAME=$DB_NAME_LOWER
        else
                DB_NAME=$DB_NAME_UPPER
     fi

# #########################
# Tablespaces Size Check:
# #########################
# Check if AUTOEXTEND OFF (MAXSIZE=0) is set for any of the datafiles divide by ALLOCATED size else divide by MAXSIZE:
VAL33=$(${ORACLE_HOME}/bin/sqlplus -S '/ as sysdba' << EOF
SELECT COUNT(*) FROM DBA_DATA_FILES WHERE MAXBYTES=0;
exit;
EOF
)
VAL44=`echo $VAL33| awk '{print $NF}'`
                case ${VAL44} in
                "0") CALCPERCENTAGE1="((sbytes - fbytes)*100 / MAXSIZE) bused " ;;
                  *) CALCPERCENTAGE1="round(((sbytes - fbytes) / sbytes) * 100,2) bused " ;;
                esac

VAL55=$(${ORACLE_HOME}/bin/sqlplus -S '/ as sysdba' << EOF
SELECT COUNT(*) FROM DBA_TEMP_FILES WHERE MAXBYTES=0;
exit;
EOF
)
VAL66=`echo $VAL55| awk '{print $NF}'`
                case ${VAL66} in
                "0") CALCPERCENTAGE2="((sbytes - fbytes)*100 / MAXSIZE) bused " ;;
                  *) CALCPERCENTAGE2="round(((sbytes - fbytes) / sbytes) * 100,2) bused " ;;
                esac

TBSCHK=$(${ORACLE_HOME}/bin/sqlplus -S "/ as sysdba" << EOF
set pages 0 termout off echo off feedback off
col tablespace for A25
col "MAXSIZE MB" format 999999
col x for 999999999 heading 'Allocated MB'
col y for 999999999 heading 'Free MB'
col z for 999999999 heading 'Used MB'
col bused for 999.99 heading '%Used'
--bre on report
spool ${LOG_DIR}/tablespaces_DBA_BUNDLE.log
select a.tablespace_name tablespace,bb.MAXSIZE/1024/1024 "MAXSIZE MB",sbytes/1024/1024 x,fbytes/1024/1024 y,
(sbytes - fbytes)/1024/1024 z,
$CALCPERCENTAGE1
--round(((sbytes - fbytes) / sbytes) * 100,2) bused
--((sbytes - fbytes)*100 / MAXSIZE) bused
from (select tablespace_name,sum(bytes) sbytes from dba_data_files group by tablespace_name ) a,
     (select tablespace_name,sum(bytes) fbytes,count(*) ext from dba_free_space group by tablespace_name) b,
     (select tablespace_name,sum(MAXBYTES) MAXSIZE from dba_data_files group by tablespace_name) bb
--where a.tablespace_name in (select tablespace_name from dba_tablespaces)
where a.tablespace_name = b.tablespace_name (+)
and a.tablespace_name = bb.tablespace_name
and round(((sbytes - fbytes) / sbytes) * 100,2) > 0
UNION ALL
select c.tablespace_name tablespace,dd.MAXSIZE/1024/1024 MAXSIZE_GB,sbytes/1024/1024 x,fbytes/1024/1024 y,
(sbytes - fbytes)/1024/1024 obytes,
$CALCPERCENTAGE2
from (select tablespace_name,sum(bytes) sbytes
      from dba_temp_files group by tablespace_name having tablespace_name in (select tablespace_name from dba_tablespaces)) c,
     (select tablespace_name,sum(bytes_free) fbytes,count(*) ext from v\$temp_space_header group by tablespace_name) d,
     (select tablespace_name,sum(MAXBYTES) MAXSIZE from dba_temp_files group by tablespace_name) dd
--where c.tablespace_name in (select tablespace_name from dba_tablespaces)
where c.tablespace_name = d.tablespace_name (+)
and c.tablespace_name = dd.tablespace_name
order by tablespace;
select tablespace_name,null,null,null,null,null||'100.00' from dba_data_files minus select tablespace_name,null,null,null,null,null||'100.00'  from dba_free_space;
spool off
exit;
EOF

TBSLOG=${LOG_DIR}/tablespaces_DBA_BUNDLE.log
TBSFULL=${LOG_DIR}/full_tbs.log
cat ${TBSLOG}|awk '{ print $1" "$NF }'| while read OUTPUT2
   do
        PRCUSED=`echo ${OUTPUT2}|awk '{print $NF}'`
        TBSNAME=`echo ${OUTPUT2}|awk '{print $1}'`
    echo "Tablespace_name          %USED" > ${TBSFULL}
    echo "----------------------          ---------------" >> ${TBSFULL}
#   echo ${OUTPUT2}|awk '{print $1"                              "$NF}' >> ${TBSFULL}
        echo "${TBSNAME}                        ${PRCUSED}%" >> ${TBSFULL}

# Convert PRCUSED from float number to integer:
PRCUSED=${PRCUSED%.*}
    if [ -z ${PRCUSED} ]
     then
      PRCUSED=1
    fi
# If the tablespace %USED >= the defined threshold send an email for each tablespace:
               if [ ${PRCUSED} -ge ${TBSTHRESHOLD} ]
                 then
mail -s "ALERT: TABLESPACE [${TBSNAME}] reached ${PRCUSED}% on database [${DB_NAME_UPPER}] on Server [${SRV_NAME}]" $MAIL_LIST < ${TBSFULL}
               fi
   done

rm -f ${LOG_DIR}/tablespaces_DBA_BUNDLE.log
rm -f ${LOG_DIR}/full_tbs.log
)

# ############################################
# Checking BLOCKING SESSIONS ON THE DATABASE:
# ############################################
VAL77=$(${ORACLE_HOME}/bin/sqlplus -S "/ as sysdba" << EOF
select count(*) from gv\$LOCK l1, gv\$SESSION s1, gv\$LOCK l2, gv\$SESSION s2
where s1.sid=l1.sid and s2.sid=l2.sid and l1.BLOCK=1 and l2.request > 0 and l1.id1=l2.id1 and l2.id2=l2.id2;
exit;
EOF
)
VAL88=`echo $VAL77| awk '{print $NF}'`
                case ${VAL88} in
                "0") ;;
                  *)
VAL99=$(${ORACLE_HOME}/bin/sqlplus -S "/ as sysdba" << EOF
set linesize 160 pages 0 echo off feedback off
col BLOCKING_STATUS for a90
spool ${LOG_DIR}/blocking_sessions.log
select 'User: '||s1.username || '@' || s1.machine || '(SID=' || s1.sid ||' ) running SQL_ID:'||s1.sql_id||'  is blocking
User: '|| s2.username || '@' || s2.machine || '(SID=' || s2.sid || ') running SQL_ID:'||s2.sql_id||' For '||s2.SECONDS_IN_WAIT||' sec
------------------------------------------------------------------------------
Warn user '||s1.username||' Or use the following statement to kill his session:
------------------------------------------------------------------------------
ALTER SYSTEM KILL SESSION '''||s1.sid||','||s1.serial#||''' immediate;' AS blocking_status
from gv\$LOCK l1, gv\$SESSION s1, gv\$LOCK l2, gv\$SESSION s2
 where s1.sid=l1.sid and s2.sid=l2.sid
 and l1.BLOCK=1 and l2.request > 0
 and l1.id1 = l2.id1
 and l2.id2 = l2.id2 ;
spool off
exit;
EOF
)
mail -s "ALERT: BLOCKING SESSIONS detected on database [${DB_NAME_UPPER}] on Server [${SRV_NAME}]" $MAIL_LIST < ${LOG_DIR}/blocking_sessions.log
rm -f ${LOG_DIR}/blocking_sessions.log
             ;;
                esac

# #########################
# Getting ALERTLOG path:
# #########################
VAL2=$(${ORACLE_HOME}/bin/sqlplus -S "/ as sysdba" <<EOF
set pages 0 feedback off;
prompt
SELECT value from v\$parameter where NAME='background_dump_dest';
exit;
EOF
)
ALERTZ=`echo $VAL2 | perl -lpe'$_ = reverse' |awk '{print $1}'|perl -lpe'$_ = reverse'`
ALERTDB=${ALERTZ}/alert_${ORACLE_SID}.log


# ###########################
# Checking Database Errors:
# ###########################

# Determine the ALERTLOG path:
    if [ -f ${ALERTDB} ]
     then
      ALERTLOG=${ALERTDB}
    elif [ -f $ORACLE_BASE/admin/${ORACLE_SID}/bdump/alert_${ORACLE_SID}.log ]
     then
      ALERTLOG=$ORACLE_BASE/admin/${ORACLE_SID}/bdump/alert_${ORACLE_SID}.log
    elif [ -f $ORACLE_HOME/diagnostics/${DB_NAME}/diag/rdbms/${DB_NAME}/${ORACLE_SID}/trace/alert_${ORACLE_SID}.log ]
     then
      ALERTLOG=$ORACLE_HOME/diagnostics/${DB_NAME}/diag/rdbms/${DB_NAME}/${ORACLE_SID}/trace/alert_${ORACLE_SID}.log
    else
      ALERTLOG=`/usr/bin/find ${ORACLE_BASE} -iname alert_${ORACLE_SID}.log  -print 2>/dev/null`
    fi

# Rename the old log generated by the script (if exists):
 if [ -f ${LOG_DIR}/alert_${ORACLE_SID}_new.log ]
  then
   mv ${LOG_DIR}/alert_${ORACLE_SID}_new.log ${LOG_DIR}/alert_${ORACLE_SID}_old.log
   # Create new log:
   tail -1000 ${ALERTLOG} > ${LOG_DIR}/alert_${ORACLE_SID}_new.log
   # Extract new entries by comparing old & new logs:
   echo "Reported By Script: ${SCRIPT_NAME}" > ${LOG_DIR}/diff_${ORACLE_SID}.log
   echo " "  >> ${LOG_DIR}/diff_${ORACLE_SID}.log
   diff ${LOG_DIR}/alert_${ORACLE_SID}_old.log ${LOG_DIR}/alert_${ORACLE_SID}_new.log |grep ">" | cut -f2 -d'>' >> ${LOG_DIR}/diff_${ORACLE_SID}.log

   # Search for errors:
   ERRORS=`cat ${LOG_DIR}/diff_${ORACLE_SID}.log | grep 'ORA-\|TNS-' |grep -Ev "ORA-2396|TNS-00507|TNS-12502|TNS-12560|TNS-12537|TNS-00505|TNS-12535"| tail -1`
   FILE_ATTACH=${LOG_DIR}/diff_${ORACLE_SID}.log

 else
   # Create new log:
   echo "Reported By Script: ${SCRIPT_NAME}" > ${LOG_DIR}/alert_${ORACLE_SID}_new.log
   echo " "  >> ${LOG_DIR}/alert_${ORACLE_SID}_new.log
   tail -1000 ${ALERTLOG} >> ${LOG_DIR}/alert_${ORACLE_SID}_new.log

   # Search for errors:
   ERRORS=`cat ${LOG_DIR}/alert_${ORACLE_SID}_new.log | grep 'ORA-\|TNS-' |grep -Ev "ORA-2396|TNS-00507|TNS-12502|TNS-12560|TNS-12537|TNS-00505|TNS-12535"| tail -1`
   FILE_ATTACH=${LOG_DIR}/alert_${ORACLE_SID}_new.log
 fi

 # Send mail in case error exist:
    case "$ERRORS" in
    *ORA-*|*TNS-*)
mail -s "ALERT: Instance [${ORACLE_SID}] on Server [${SRV_NAME}] reporting errors: ${ERRORS}" ${MAIL_LIST} < ${FILE_ATTACH}
    esac

# #####################
# Reporting Offline DBs:
# #####################
# Populate ${LOG_DIR}/alldb_DBA_BUNDLE.log from ORATAB:
# grep -v '^\#' $ORATAB | grep -v "ASM" |grep -v "${DB_NAME}:"| grep -v '^$' | grep "^" | cut -f1 -d':' > ${LOG_DIR}/alldb_DBA_BUNDLE.log
  grep -v '^\#' $ORATAB | grep -v "ASM" |grep -v "${DB_NAME_LOWER}:"| grep -v "${DB_NAME_UPPER}:"|  grep -v '^$' | grep "^" | cut -f1 -d':' > ${LOG_DIR}/alldb_DBA_BUNDLE.log

# Populate ${LOG_DIR}/updb_DBA_BUNDLE.log:
  echo $ORACLE_SID >> ${LOG_DIR}/updb_DBA_BUNDLE.log
  echo $DB_NAME >> ${LOG_DIR}/updb_DBA_BUNDLE.log

# End looping for databases:
done

# Continue Reporting Offline DBs...
# Sort the lines alphabetically with removing duplicates:
sort ${LOG_DIR}/updb_DBA_BUNDLE.log  | uniq -d > ${LOG_DIR}/updb_DBA_BUNDLE.log.sort
sort ${LOG_DIR}/alldb_DBA_BUNDLE.log > ${LOG_DIR}/alldb_DBA_BUNDLE.log.sort
diff ${LOG_DIR}/alldb_DBA_BUNDLE.log.sort ${LOG_DIR}/updb_DBA_BUNDLE.log.sort > ${LOG_DIR}/diff_DBA_BUNDLE.sort
echo "The Following Instances are Down on $SRV_NAME :" > ${LOG_DIR}/offdb_DBA_BUNDLE.log
grep "^< " ${LOG_DIR}/diff_DBA_BUNDLE.sort | cut -f2 -d'<' >> ${LOG_DIR}/offdb_DBA_BUNDLE.log
echo " " >> ${LOG_DIR}/offdb_DBA_BUNDLE.log
echo "If those instances are permanently offline, please hash their entries in $ORATAB to let the script ignore them in the next run." >> ${LOG_DIR}/offdb_DBA_BUNDLE.log
OFFLINE_DBS_NUM=`cat ${LOG_DIR}/offdb_DBA_BUNDLE.log| wc -l`

# If OFFLINE_DBS is not null:
    if [ ${OFFLINE_DBS_NUM} -gt 3 ]
     then
mail -s "ALARM: Database Down on Server: [$SRV_NAME]" $MAIL_LIST < ${LOG_DIR}/offdb_DBA_BUNDLE.log
    fi

# Wiping Logs:
#cat /dev/null >  ${LOG_DIR}/updb_DBA_BUNDLE.log
#cat /dev/null >  ${LOG_DIR}/alldb_DBA_BUNDLE.log
#cat /dev/null >  ${LOG_DIR}/updb_DBA_BUNDLE.log.sort
#cat /dev/null >  ${LOG_DIR}/alldb_DBA_BUNDLE.log.sort
#cat /dev/null >  ${LOG_DIR}/diff_DBA_BUNDLE.sort

rm -f ${LOG_DIR}/updb_DBA_BUNDLE.log
rm -f ${LOG_DIR}/alldb_DBA_BUNDLE.log
rm -f ${LOG_DIR}/updb_DBA_BUNDLE.log.sort
rm -f ${LOG_DIR}/alldb_DBA_BUNDLE.log.sort
rm -f ${LOG_DIR}/diff_DBA_BUNDLE.sort


# ###########################
# Checking Listeners log:
# ###########################

# In case there is NO Listeners are running send an (Alarm):
LSN_COUNT=$( ps -ef|grep -v grep|grep tnslsnr|wc -l )

 if [ $LSN_COUNT -eq 0 ]
  then
   echo "The following are the processes running by user ${ORA_USER} on server ${SRV_NAME}:" > ${LOG_DIR}/listener_processes.log
   echo " " >> ${LOG_DIR}/listener_processes.log
   ps -ef|grep -v grep|grep oracle >> ${LOG_DIR}/listener_processes.log
mail -s "ALARM: No Listeners Are Running on Server: $SRV_NAME !!!" $MAIL_LIST < ${LOG_DIR}/listener_processes.log

  # In case there is a listener running analyze it's log:
  else
    for LISTENER_NAME in $( ps -ef|grep -v grep|grep tnslsnr|awk '{print $(NF-1)}' )
     do
      LISTENER_HOME=`ps -ef|grep -v grep|grep tnslsnr|grep "${LISTENER_NAME} "|awk '{print $(NF-2)}' |sed -e 's/\/bin\/tnslsnr//g'|grep -v sed|grep -v "s///g"`
      TNS_ADMIN=${LISTENER_HOME}/network/admin; export TNS_ADMIN
      LISTENER_LOGDIR=`${LISTENER_HOME}/bin/lsnrctl status ${LISTENER_NAME} |grep "Listener Log File"| awk '{print $NF}'| sed -e 's/\/alert\/log.xml//g'`
      LISTENER_LOG=${LISTENER_LOGDIR}/trace/${LISTENER_NAME}.log

      # Determine if the listener name is in Upper/Lower case:
            if [ -f  ${LISTENER_LOG} ]
             then
          # Listner_name is Uppercase:
              LISTENER_NAME=$( echo ${LISTENER_NAME} | perl -lpe'$_ = reverse' |perl -lpe'$_ = reverse' )
              LISTENER_LOG=${LISTENER_LOGDIR}/trace/${LISTENER_NAME}.log
            else
          # Listener_name is Lowercase:
              LISTENER_NAME=$( echo "${LISTENER_NAME}" | tr -s  '[:upper:]' '[:lower:]' )
              LISTENER_LOG=${LISTENER_LOGDIR}/trace/${LISTENER_NAME}.log
            fi

      # Rename the old log (If exists):
      if [ -f ${LOG_DIR}/alert_${LISTENER_NAME}_new.log ]
       then
          mv ${LOG_DIR}/alert_${LISTENER_NAME}_new.log ${LOG_DIR}/alert_${LISTENER_NAME}_old.log
        # Create a new log:
          tail -1000 ${LISTENER_LOG} > ${LOG_DIR}/alert_${LISTENER_NAME}_new.log
        # Get the new entries:
          echo "Reported By Script: ${SCRIPT_NAME}" > ${LOG_DIR}/diff_${LISTENER_NAME}.log
          echo " " >> ${LOG_DIR}/diff_${LISTENER_NAME}.log
          diff ${LOG_DIR}/alert_${LISTENER_NAME}_old.log  ${LOG_DIR}/alert_${LISTENER_NAME}_new.log | grep ">" | cut -f2 -d'>' >> ${LOG_DIR}/diff_${LISTENER_NAME}.log
        # Search for errors:
         #ERRORS=`cat ${LOG_DIR}/diff_${LISTENER_NAME}.log|grep "TNS-"|grep -v "TNS-00507"|grep -v "TNS-12502"|grep -v "TNS-12560"|grep -v "TNS-12537"|tail -1`
         ERRORS=`cat ${LOG_DIR}/diff_${LISTENER_NAME}.log|grep "TNS-"|grep -Ev "TNS-00507|TNS-12502|TNS-12560|TNS-12537|TNS-00505|TNS-12535"|tail -1`
         SRVC_REG=`cat ${LOG_DIR}/diff_${LISTENER_NAME}.log| grep "service_register" `
         FILE_ATTACH=${LOG_DIR}/diff_${LISTENER_NAME}.log

     # If no old logs exist:
     else
        # Just create a new log without doing any comparison:
             echo "Reported By Script: ${SCRIPT_NAME}" > ${LOG_DIR}/alert_${LISTENER_NAME}_new.log
         echo " " >> ${LOG_DIR}/alert_${LISTENER_NAME}_new.log
             tail -1000 ${LISTENER_LOG} >> ${LOG_DIR}/alert_${LISTENER_NAME}_new.log

            # Search for errors:
              ERRORS=`cat ${LOG_DIR}/alert_${LISTENER_NAME}_new.log|grep "TNS-"|grep -Ev "TNS-00507|TNS-12502|TNS-12560|TNS-12537|TNS-00505|TNS-12535"|tail -1`
              SRVC_REG=`cat ${LOG_DIR}/alert_${LISTENER_NAME}_new.log | grep "service_register" `
              FILE_ATTACH=${LOG_DIR}/alert_${LISTENER_NAME}_new.log
     fi

          # Report TNS Errors (Alert)
            case "$ERRORS" in
            *TNS-*)
mail -s "ALERT: Listener [${LISTENER_NAME}] on Server [${SRV_NAME}] reporting errors: ${ERRORS}" $MAIL_LIST < ${FILE_ATTACH}
            esac

          # Report Registered Services to the listener (Info)
            case "$SRVC_REG" in
            *service_register*)
mail -s "INFO: Service Registered on Listener [${LISTENER_NAME}] on Server [${SRV_NAME}] | TNS poisoning posibility" $MAIL_LIST < ${FILE_ATTACH}
            esac

    done
 fi

# #############
# END OF SCRIPT
# #############
# REPORT BUGS to: mahmmoudadel@hotmail.com
# DOWNLOAD THE LATEST VERSION OF DATABASE ADMINISTRATION BUNDLE FROM:
# http://dba-tips.blogspot.com/2014/02/oracle-database-administration-scripts.html
# DISCLAIMER: THIS SCRIPT IS DISTRIBUTED IN THE HOPE THAT IT WILL BE USEFUL, BUT WITHOUT ANY WARRANTY. IT IS PROVIDED "AS IS".
