#!/bin/sh
#--File: CHKALERT.sh

#--setup
PGM="CHKALERT"
ALRT=$HOME/alert
LST=${ALRT}/lst
LOG=${LST}/${PGM}.log
CURR=${ALRT}/${PGM}.curr

#--Unix environment variables
ECHO=echo;          export ECHO
CAT=/bin/cat;       export CAT
RM=/bin/rm;         export RM
TOUCH=/bin/touch;   export TOUCH
GREP=/bin/grep;     export GREP
AWK=/bin/awk;       export AWK
WC=/usr/bin/wc;     export WC
TAIL=/usr/bin/tail; export TAIL
HEAD=/usr/bin/head; export HEAD
SUM=/usr/bin/sum;   export SUM

#--Oracle environment variables
ORACLE_SID=db11;             export ORACLE_SID
ORACLE_HOME=`${GREP} ${ORACLE_SID}: /etc/oratab | ${AWK} -F: '{print $2}'`; export ORACLE_HOME
PATH=$ORACLE_HOME/bin:$PATH; export PATH

#--code
start=`date "+%Y:%m:%d:%H:%M:%S"`
${RM} ${LOG}
${TOUCH} ${LOG}

#--execute SQL to get some diagnostic variables
echo "set echo     off"                                                    > ${LST}/${PGM}.sql
echo "set feedback off"                                                   >> ${LST}/${PGM}.sql
echo "set heading  off"                                                   >> ${LST}/${PGM}.sql
echo "set linesize  40"                                                   >> ${LST}/${PGM}.sql
echo "set pagesize  55"                                                   >> ${LST}/${PGM}.sql
echo "set verify   off"                                                   >> ${LST}/${PGM}.sql
echo "set linesize 300"                                                   >> ${LST}/${PGM}.sql
echo "SELECT 'homepath:'||replace(homepath.value,adrbase.value||'/','')"  >> ${LST}/${PGM}.sql
echo "  FROM v\$diag_info homepath, v\$diag_info adrbase"                 >> ${LST}/${PGM}.sql
echo " WHERE homepath.name = 'ADR Home'"                                  >> ${LST}/${PGM}.sql
echo "   AND adrbase.name  = 'ADR Base';"                                 >> ${LST}/${PGM}.sql
echo "SELECT     'day:'||to_char(sysdate  ,'yyyy-mm-dd') FROM dual;"      >> ${LST}/${PGM}.sql
echo "SELECT 'nextday:'||to_char(sysdate+1,'yyyy-mm-dd') FROM dual;"      >> ${LST}/${PGM}.sql
echo "SELECT 'prevday:'||to_char(sysdate-1,'yyyy-mm-dd') FROM dual;"      >> ${LST}/${PGM}.sql
echo "exit"                                                               >> ${LST}/${PGM}.sql
sqlplus -s '/as sysdba' @${LST}/${PGM}.sql                         > ${LST}/${PGM}.lst

#-- get diag information variables just queried from the database
homepath=`${GREP} homepath               ${LST}/${PGM}.lst | ${AWK} -F":" '{print $2}'`
     day=`${GREP} "^day"                 ${LST}/${PGM}.lst | ${AWK} -F":" '{print $2}'`
 nextday=`${GREP} nextday                ${LST}/${PGM}.lst | ${AWK} -F":" '{print $2}'`
 prevday=`${GREP} prevday                ${LST}/${PGM}.lst | ${AWK} -F":" '{print $2}'`

#-- get the timezone from the alert log (safest place to get)
#-- the proper timezone is needed to properly filter the alert log for date ranges you
#--   want to look at
echo "set echo off"                             > ${LST}/${PGM}.adrci
echo "set termout off"                         >> ${LST}/${PGM}.adrci
echo "set homepath ${homepath}"                >> ${LST}/${PGM}.adrci
echo "spool ${LST}/${PGM}.tmp"                 >> ${LST}/${PGM}.adrci
echo "show alert -tail 1"                      >> ${LST}/${PGM}.adrci
echo "spool off"                               >> ${LST}/${PGM}.adrci
adrci script=${LST}/${PGM}.adrci       1>/dev/null 2>/dev/null
timezone=`${HEAD} -1 ${LST}/${PGM}.tmp | ${AWK} -F" " '{print $3}'`

#-- extract alert log errors for the current day (today) and previous day (yesterday)
#-- previous day alerts will be used if the current file has yesterday's day as last day;
#--   meaning that we have had a switch to a new day and might have errors still to
#--   process from the previous day
echo "set echo off"                             > ${LST}/${PGM}.adrci
echo "set termout off"                         >> ${LST}/${PGM}.adrci
echo "set homepath ${homepath}"                >> ${LST}/${PGM}.adrci
echo "spool ${LST}/${PGM}.${day}"              >> ${LST}/${PGM}.adrci
echo "show alert -P \"ORIGINATING_TIMESTAMP BETWEEN '${day} 00:00:00.000000 ${timezone}' AND
'${nextday} 00:00:00.000000 ${timezone}' AND MESSAGE_TEXT LIKE '%ORA-%'\" -term" >>
${LST}/${PGM}.adrci
echo "spool off"                               >> ${LST}/${PGM}.adrci
echo "spool ${LST}/${PGM}.${prevday}"  >> ${LST}/${PGM}.adrci
echo "show alert -P \"ORIGINATING_TIMESTAMP BETWEEN '${prevday} 00:00:00.000000 ${timezone}' AND
'${day} 00:00:00.000000 ${timezone}' AND MESSAGE_TEXT LIKE '%ORA-%'\" -term" >>
${LST}/${PGM}.adrci
echo "spool off"                               >> ${LST}/${PGM}.adrci
adrci script=${LST}/${PGM}.adrci       1>/dev/null 2>/dev/null

#-- get current contents of the current file
#-- default to current day if no current file
if [ -r "${CURR}" ]
then
  #-- if the current exists then get the information it contains
  daychecksum=`${GREP} day ${CURR} | ${AWK} -F":" '{print $2}'`
  daylastline=`${GREP} day ${CURR} | ${AWK} -F":" '{print $3}'`
   daylastday=`${GREP} day ${CURR} | ${AWK} -F":" '{print $4}'`
else
  #-- if the current does not exist then default to today
  daychecksum=0
  daylastline=3
   daylastday=${day}
fi

#-- set the days to search through for alerts
#-- if last day in current file was yesterday then include previous day
#-- if last day in current file is not yesterday then just scan today's alerts
if [ "${daylastday}" = "${prevday}" ]
then
  alertdays="${prevday} ${day}"
else
  alertdays="${day}"
fi

#-- for each of the days to scan for alerts
for theday in ${alertdays}
do
 #-- check alert errors for the last day.
 if [ -r "${LST}/${PGM}.${theday}" ]
 then
  #-- If the checksum generated is DIFFERENT we should start reporting from the top.
  #--
  #-- If the checksum generated is the SAME we should start reporting from end of
  #-- the previously generated output.
  new_daychecksum=`${HEAD} -4 ${LST}/${PGM}.${theday} | ${SUM} | ${AWK} '{print $1}'`
  if [ ${new_daychecksum} -ne ${daychecksum} ]
  then
   daychecksum=${new_daychecksum}
   daylastline=3
  fi

  #-- get the number of lines in the generated errors so we can report to the
  #-- end of the file and we know where to start next time.
  new_daylastline=`${WC} -l ${LST}/${PGM}.${theday} | ${AWK} -F" " '{print $1}'`

  #-- if the number of lines in the output is 3 then there are no errors found.
  if [ ${new_daylastline} -ne 3 ]
  then
   #-- if number of lines in extracted alerts is the same as last time then no new alerts
   if [ ${new_daylastline} -ne ${daylastline} ]
   then
    #-- find the line to begin reporting new alerts from
    fromline=`expr ${new_daylastline} - ${daylastline}`
    #-- produce alert lines for alerts defined in file CHKALERT
    ${TAIL} -${fromline} ${LST}/${PGM}.${theday} |
    while read LINE
    do
     for ORAS in `${CAT} ${ALRT}/CHKALERT`
     do
       ora=`${ECHO} ${LINE} | ${GREP} ${ORAS}`
      if [ $? -eq 0 ]
      then
       #-- you might want to do something here
       #--  that is specific to certain ORA- errors
       err="001"
       echo "${err}:${start}:${LINE}"  >> ${LOG}
      fi
     done
    done
   fi
  fi
  daylastline=${new_daylastline}
  #-- update the current file only if the day being processed is current day
  if [ "${theday}" = "${day}" ]
  then
   ${ECHO} "day:"${daychecksum}":"${daylastline}":"${day} > ${CURR}
  fi
fi
done
