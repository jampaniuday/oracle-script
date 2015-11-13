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
#sh_dir=$sh_dir;
#log_dir=$log_dir;

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


CHECK_STR='WARNING|fail|errs|ORA-|abort|corrupt|bad|not complete|heatbeat|timeout'


v_p=`grep "V_ORA_HEA_OCSSDLOGSIZE" $para_dir |awk -F= '{print $2}'`;
if  [ -z "$v_p" ];then
v_p=100
fi
v_logname=`grep "V_ORA_HEA_OCSSDLOGPATH" $para_dir|awk -F= '{print $2}'`;
if [ -z "$v_logname" ];then
v_logname="/home/db/grid/product/11.2.0/log/`hostname`/cssd/ocssd.log"
fi
v_lognum=`echo $v_logname|grep ocssd.log|wc -l`;



if [ $v_lognum -gt 0 ];then
	if [ -f $v_logname ];then
#first time to check ocssd.log
		if [ ! -f $log_dir/ocssdtotalline.log ];then
#增加heatbeat|timeout
			cat $v_logname|grep -wE "$CHECK_STR"|grep -v  '[(A-Za-z0-9]\{1,5\}.ora'|egrep -i -v "clssgmDeadProc" > $log_dir/ocerror.log;
#ocssd.log including errors
				if [ `cat $log_dir/ocerror.log|wc -l` -gt 0 ];then

					if [ `du -sk $v_logname|awk '{print $1}'` -gt `expr $v_p \* 1024` ];then
						echo "1";
						echo "ocssd.log 超过 ["$v_p"m] 并包含 [${CHECK_STR}]:" >$log_dir/DBCHK_ORA_OCSSDLOGERROR_RES.out;
						cat $v_logname|grep -iwE "$CHECK_STR"|grep -v  '[(A-Za-z0-9]\{1,5\}.ora' >> $log_dir/DBCHK_ORA_OCSSDLOGERROR_RES.out;
						cat $v_logname|wc -l > $log_dir/ocssdtotalline.log;
					else
						echo "1";
						echo "ocssd.log包含 [${CHECK_STR}]:" >$log_dir/DBCHK_ORA_OCSSDLOGERROR_RES.out;
						cat $v_logname|grep -iwE "$CHECK_STR"|grep -v  '[(A-Za-z0-9]\{1,5\}.ora' >> $log_dir/DBCHK_ORA_OCSSDLOGERROR_RES.out;
						cat $v_logname|wc -l > $log_dir/ocssdtotalline.log;

					fi
#no errors
				else
					if [ `du -sk $v_logname|awk '{print $1}'` -gt `expr $v_p \* 1024` ];then
						echo "1";
						echo "ocssd.log 包含 ["$v_p"m] 但没有 [$CHECK_STR]" > $log_dir/DBCHK_ORA_OCSSDLOGERROR_RES.out;
						cat $v_logname|wc -l > $log_dir/ocssdtotalline.log;
					else
						echo "0";
						echo '正常 [阀值='$v_p'm]' > $log_dir/DBCHK_ORA_OCSSDLOGERROR_RES.out;
						cat $v_logname|wc -l > $log_dir/ocssdtotalline.log;
					fi
				fi
			rm -f $log_dir/ocerror.log;
#not first time to check ocssd.log
			else
				v_tonum=`cat $log_dir/ocssdtotalline.log|wc -l`;

				if [ $v_tonum -gt 0 ];then
					v_linelas=`cat $log_dir/ocssdtotalline.log`;
				else
					v_linelas=0;
				fi

				v_toline=`cat $v_logname|wc -l`;
				v_neline=`expr $v_toline - $v_linelas`;
				tail -$v_neline $v_logname|grep -iwE "$CHECK_STR"|grep -v  '[(A-Za-z0-9]\{1,5\}.ora' > $log_dir/ocerrorb.log;
#including errors
				if [ `cat $log_dir/ocerrorb.log|wc -l` -gt 0 ];then
					if [ `du -sk $v_logname|awk '{print $1}'` -gt `expr $v_p \* 1024` ];then
						echo "1";
						echo "ocssd.log 超过 ["$v_p"m] 并包含 [$CHECK_STR]:" >$log_dir/DBCHK_ORA_OCSSDLOGERROR_RES.out;
						tail -$v_neline $v_logname|grep -iwE "$CHECK_STR"|grep -v  '[(A-Za-z0-9]\{1,5\}.ora' >> $log_dir/DBCHK_ORA_OCSSDLOGERROR_RES.out;
						cat $v_logname|wc -l > $log_dir/ocssdtotalline.log;
					else
						echo "1";
						echo "ocssd.log中包含 [${CHECK_STR}]">$log_dir/DBCHK_ORA_OCSSDLOGERROR_RES.out;
						tail -$v_neline $v_logname|grep -iwE "$CHECK_STR"|grep -v  '[(A-Za-z0-9]\{1,5\}.ora' >> $log_dir/DBCHK_ORA_OCSSDLOGERROR_RES.out;
						cat $v_logname|wc -l > $log_dir/ocssdtotalline.log;
					fi
#no errors
				else

					if [ `du -sk $v_logname|awk '{print $1}'` -gt `expr $v_p \* 1024` ];then
						echo "2";
						echo "ocssd.log 超过 ['$v_p'm] 但没有 [${CHECK_STR}]" > $log_dir/DBCHK_ORA_OCSSDLOGERROR_RES.out;
						cat $v_logname|wc -l > $log_dir/ocssdtotalline.log;
					else
						echo "0";
						echo '正常 [阀值='$v_p'm]' > $log_dir/DBCHK_ORA_OCSSDLOGERROR_RES.out;
						cat $v_logname|wc -l > $log_dir/ocssdtotalline.log;
					fi

				fi

				rm -f $log_dir/ocerrorb.log;
			fi

		else
			echo "1";
			echo "未找到ocssd.log,在[V_ORA_HEA_OCSSDLOGPATH]阀值中定义的路径不正确" >$log_dir/DBCHK_ORA_OCSSDLOGERROR_RES.out;
		fi

	else
		echo "1";
		echo "未找到ocssd.log,请在[V_ORA_HEA_OCSSDLOGPATH]的阀值定义其路径" >$log_dir/DBCHK_ORA_OCSSDLOGERROR_RES.out;
fi

#echo $?;
#print result
cat $log_dir/${filename%%.sh}.out

exit 0
