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


for i in `cat -n $log_dir/oracount.list|awk '{print $1}'`
do
v_para=`cat $log_dir/oracount.list|head \`echo -$i\`|tail -1`
username=`echo $v_para|awk '{print $1}'`
sid=`echo $v_para|awk '{print $2}'`;

#chown $username $log_dir/healthchecklog3;
#tmp_dir=$log_dir/healthchecklog3;

#su - $username -c "export ORACLE_SID=$sid;sh $sh_dir/sqloracle_blockcorruption.sql" > $log_dir/block.log;
#rm $log_dir/block.log;

chown $username $tmp_dir
[ -f $tmp_dir/DBCHK_ORA_BLOCKCORRUPTION_RES2.out ] && rm -f $tmp_dir/DBCHK_ORA_BLOCKCORRUPTION_RES2.out
#su oracle,exec sql
su - $username 2>&1 1>/dev/null <<EOF
export ORACLE_SID=$sid;
sqlplus "/as sysdba";
set linesize 300;
set heading off;
set feedback off;
set pagesize 10000
SET SQLPROMPT "SQL>";
spool $tmp_dir/DBCHK_ORA_BLOCKCORRUPTION_RES2.out;
select 'BLOCK='||file#||','||block#  AA from v\$database_block_corruption;
spool off;
quit;
EOF


v_num=`cat $tmp_dir/DBCHK_ORA_BLOCKCORRUPTION_RES2.out|grep -v AA|grep 'BLOCK='|wc -l`

if [ $v_num -gt 0 ]
then
#echo "Non-Compliant";
resulta=`echo \`expr $resulta + 1\``;
echo "数据库实例"$sid": 不正常" >> $log_dir/DBCHK_ORA_BLOCKCORRUPTION_RES.out;
echo "存在的坏块如下:" > $log_dir/DBCHK_ORA_BLOCKCORRUPTION_RES.out;
cat $tmp_dir/DBCHK_ORA_BLOCKCORRUPTION_RES2.out|grep -v AA|grep 'BLOCK='|awk -F= '{print $2}'>>$log_dir/DBCHK_ORA_BLOCKCORRUPTION_RES.out;
else
#echo "Compliant";
echo '数据库实例'$sid': 正常' >> $log_dir/DBCHK_ORA_BLOCKCORRUPTION_RES.out;
fi

done


if [ $resulta -eq 0 ]
then
	echo "$Compliant"
else
	echo "$NonCompliant"
fi

#print result
cat $log_dir/${filename%%.sh}.out

exit 0
