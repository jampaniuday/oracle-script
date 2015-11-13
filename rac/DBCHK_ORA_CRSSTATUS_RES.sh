#!/bin/sh
#############################################################
###Write by fusc 20110415
###This script is a health check script of oracle database
###Edit by ycl 20120730
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


v_cnum=`echo $PATH|grep 'crs/bin'|wc -l`;
which crs_stat >/dev/null
if [ $? -eq 0 ];then
crs_stat -t|grep '^ora' > $log_dir/DBCHK_ORA_CRSSTATUS_RES2.out;
	if [ `crs_stat -t -v |grep OFFLINE|wc -l` -gt 0 ];then
		echo "$NonCompliant";
		echo "不正常 以下的CRS组件状态不是[online]:" > $log_dir/DBCHK_ORA_CRSSTATUS_RES.out;
		cat $log_dir/DBCHK_ORA_CRSSTATUS_RES2.out|grep -v ONLINE >> $log_dir/DBCHK_ORA_CRSSTATUS_RES.out;
	else
		echo "$Compliant";
		echo '正常' > $log_dir/DBCHK_ORA_CRSSTATUS_RES.out;
	fi
else
	echo "$NonCompliant";
	echo "找不到crs_stat命令，请将crs的命令加入到root的PATH中" > $log_dir/DBCHK_ORA_CRSSTATUS_RES.out;
fi

#echo $?
#print result
cat $log_dir/${filename%%.sh}.out

exit 0
