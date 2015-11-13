#!/bin/sh
#############################################################
###Write by fusc 20110415
###This script is a health check script of oracle database
#############################################################
VERSION="1"
MODIFIED_TIME="20140415"
DEPLOY_UNION="COMMON"
EDITER_MAIL="iomp.zh@ccb.com"

LANG=en_US.utf8
sh_dir=/home/ap/opscloud/health_check/ORACLE
log_dir=/home/ap/opscloud/logs
para_dir=/home/ap/opscloud/V_COMMON.cfg
tmp_dir=$log_dir/oracle
Compliant=0
NonCompliant=1
Log=2
filename=`basename $0`
[ -d ${log_dir} ] || mkdir -p ${log_dir}
[ -d ${tmp_dir} ] || mkdir -p ${tmp_dir}
[ -f /home/ap/opscloud/logs/${filename%%.sh}.out ] && rm /home/ap/opscloud/logs/${filename%%.sh}.out
ps -ef |grep ora_smon |grep -v grep|awk  '{print $1, substr($NF,10)}'>$log_dir/oracount.list


resulta=0


v_p=`grep "V_ORA_HEA_RECEIVETIME" $para_dir |awk -F= '{print $2}'|head -1`;
if [[ -z "$v_p" ]];then
v_p=5
fi

for i in `cat -n $log_dir/oracount.list|awk '{print $1}'`
do
v_para=`cat $log_dir/oracount.list|head \`echo -$i\`|tail -1`
username=`echo $v_para|awk '{print $1}'`
sid=`echo $v_para|awk '{print $2}'`;

#chown $username $log_dir/healthchecklogreceivetime;
#tmp_dir=$log_dir/healthchecklogreceivetime;

#su - $username -c "export ORACLE_SID=$sid;sh $sh_dir/sqloracle_receivetime.sql" > $log_dir/pga.log;


#add oracle priv
chown $username $tmp_dir
[ -f $tmp_dir/DBCHK_ORA_VERSION_RES2.out ] && rm -f $tmp_dir/DBCHK_ORA_VERSION_RES2.out
#su oracle,exec sql
su - $username 2>&1 1>/dev/null <<EOF
export ORACLE_SID=$sid;
sqlplus "/as sysdba";
set linesize 300;
set heading off;
set feedback off;
set pagesize 10000
SET SQLPROMPT "SQL>";
spool $tmp_dir/DBCHK_ORA_RECEIVETIME_RES2.out;
select 'AVGRECE='||((b1.value/b2.value)*10) AA from gv\$sysstat b1,gv\$sysstat b2 where b1.name='global cache cr block receive time' and b2.name='global cache cr blocks received' and b1.inst_id=b2.inst_id;
spool off;
quit;
EOF

v_num=`cat $tmp_dir/DBCHK_ORA_RECEIVETIME_RES2.out|grep -v AA|grep 'AVGRECE='|awk -F= '{print $2}'`

if [ $v_num -gt $v_p ]
then
	#echo "Non-Compliant";
	resulta=`echo \`expr $resulta + 1\``
	echo "数据库实例"$sid": 不正常" >> $log_dir/DBCHK_ORA_RECEIVETIME_RES.out;
	echo "RAC节点之间数据块接收平均时间超过 ["$v_p"ms]" >> $log_dir/DBCHK_ORA_RECEIVETIME_RES.out
else
#echo "Compliant";
	echo '数据库实例'$sid': 正常 [阀值='$v_p'ms]' >> $log_dir/DBCHK_ORA_RECEIVETIME_RES.out;
fi
done




if [ $resulta -ne 0 ]
then
echo "$NonCompliant";
else
echo "$Compliant";
fi
#echo $?


#print result
cat $log_dir/${filename%%.sh}.out

exit 0