#!/bin/sh
#############################################################
###Write by YCL 20130831
###CHECK RAC +ASM FILESYSTEM 
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

v_num=`/home/db/grid/product/11.2.0/bin/crsctl query css votedisk |grep 'ONLINE'|wc -l`
s_num=`/home/db/grid/product/11.2.0/bin/crsctl query css votedisk |grep '\[SYS\]'|wc -l`
#v_num=`crsctl query css votedisk |grep 'ONLINE'|wc -l`
#s_num=`crsctl query css votedisk |grep '\[SYS\]'|wc -l`

if [ $v_num -eq 3  -a $s_num -eq 3 ]
then
  echo '数据库实例'$sid': 正常' > $log_dir/DBCHK_ORA_VOTEDISKCHECK_RES.out;
else
#echo "Compliant";
  let resulta=resulta+1
  echo '数据库实例'$sid': 不正常' > $log_dir/DBCHK_ORA_VOTEDISKCHECK_RES.out;
/home/db/grid/product/11.2.0/bin/crsctl query css votedisk >> $log_dir/DBCHK_ORA_VOTEDISKCHECK_RES.out;
#crsctl query css votedisk >> $log_dir/DBCHK_ORA_VOTEDISKCHECK_RES.out;
fi

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
