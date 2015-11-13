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



v_p=`grep "V_ORA_HEA_CRSDLOGSIZE" $para_dir|awk -F= '{print $2}'|head -1`;
if [ -z "$v_p" ];then
	v_p=100
fi
v_logname=`grep "V_ORA_HEA_CRSDLOGPATH" $para_dir|awk -F= '{print $2}'`;
if [ -z "$v_logname" ];then
	v_logname="/home/db/grid/product/11.2.0/log/`hostname`/crsd/crsd.log"
fi

v_lognum=`echo $v_logname|grep crsd.log|wc -l`;


if [ $v_lognum -gt 0 ];then

	if [ -f $v_logname ];then


	#first time to check crsd.log
		if [ ! -f $log_dir/crsdtotalline.log ];then
			cat $v_logname|grep -wE 'WARNING|fail|errs|ORA-|abort|corrupt|bad|not complete'|grep -v  '[(A-Za-z0-9]\{1,5\}.ora' |egrep -v -i " connect failed, rc"> $log_dir/error.log;
		#crsd.log including errors
			if [ `cat $log_dir/error.log|wc -l` -gt 0 ];then

				if [ `du -sk $v_logname|awk '{print $1}'` -gt `expr $v_p \* 1024` ];then
					echo "1";
					echo 'crsd.log 超过 ['$v_p'm] 并包含 [WARNING|fail|errs|ORA-|abort|corrupt|bad|not complete]:' >$log_dir/DBCHK_ORA_CRSDLOGERROR_RES.out;
					cat $v_logname|grep -iwE 'WARNING|fail|errs|ORA-|abort|corrupt|bad|not complete'|grep -v  '[(A-Za-z0-9]\{1,5\}.ora' >> $log_dir/DBCHK_ORA_CRSDLOGERROR_RES.out;
					cat $v_logname|wc -l > $log_dir/crsdtotalline.log;
				else
					echo "1";
					echo 'crsd.log包含 [WARNING|fail|errs|ORA-|abort|corrupt|bad|not complete]:' >$log_dir/DBCHK_ORA_CRSDLOGERROR_RES.out;
					cat $v_logname|grep -iwE 'WARNING|fail|errs|ORA-|abort|corrupt|bad|not complete'|grep -v  '[(A-Za-z0-9]\{1,5\}.ora' >> $log_dir/DBCHK_ORA_CRSDLOGERROR_RES.out;
					cat $v_logname|wc -l > $log_dir/crsdtotalline.log;

				fi




			#no errors
			else


				if [ `du -sk $v_logname|awk '{print $1}'` -gt `expr $v_p \* 1024` ];then
					echo "1";
					echo 'crsd.log 包含 ['$v_p'm] 但没有 [WARNING][fail][errs][ORA-][abort][corrupt][bad][not complete]' > $log_dir/DBCHK_ORA_CRSDLOGERROR_RES.out;
					cat $v_logname|wc -l > $log_dir/crsdtotalline.log;
				else
					echo "0";
					echo '正常 [阀值='$v_p'm]' > $log_dir/DBCHK_ORA_CRSDLOGERROR_RES.out;
					cat $v_logname|wc -l > $log_dir/crsdtotalline.log;
				fi



			fi

			rm -f $log_dir/error.log;

#not first time to check crsd.log

		else



			v_tonum=`cat $log_dir/crsdtotalline.log|wc -l`;

			if [ $v_tonum -gt 0 ];then
				v_linelas=`cat $log_dir/crsdtotalline.log`;
			else
				v_linelas=0;
			fi

			v_toline=`cat $v_logname|wc -l`;
			v_neline=`expr $v_toline - $v_linelas`;
			tail -$v_neline $v_logname|grep -iwE 'WARNING|fail|errs|ORA-|abort|corrupt|bad|not complete'|grep -v  '[(A-Za-z0-9]\{1,5\}.ora' > $log_dir/errorb.log;
#including errors
			if [ `cat $log_dir/errorb.log|wc -l` -gt 0 ];then

				if [ `du -sk $v_logname|awk '{print $1}'` -gt `expr $v_p \* 1024` ];then
					echo "1";
					echo 'crsd.log 超过 ['$v_p'm] 并包含 [WARNING|fail|errs|ORA-|abort|corrupt|bad|not complete]:' >$log_dir/DBCHK_ORA_CRSDLOGERROR_RES.out;
					tail -$v_neline $v_logname|grep -iwE 'WARNING|fail|errs|ORA-|abort|corrupt|bad|not complete'|grep -v  '[(A-Za-z0-9]\{1,5\}.ora' >> $log_dir/DBCHK_ORA_CRSDLOGERROR_RES.out;
					cat $v_logname|wc -l > $log_dir/crsdtotalline.log;
				else
					echo "1";
					echo 'crsd.log中包含 [WARNING|fail|errs|ORA-|abort|corrupt|bad|not complete]:' >$log_dir/DBCHK_ORA_CRSDLOGERROR_RES.out;
					tail -$v_neline $v_logname|grep -iwE 'WARNING|fail|errs|ORA-|abort|corrupt|bad|not complete'|grep -v  '[(A-Za-z0-9]\{1,5\}.ora' >> $log_dir/DBCHK_ORA_CRSDLOGERROR_RES.out;
					cat $v_logname|wc -l > $log_dir/crsdtotalline.log;
				fi
#no errors
			else

				if [ `du -sk $v_logname|awk '{print $1}'` -gt `expr $v_p \* 1024` ];then
					echo "No-0";
					echo 'crsd.log 超过 ['$v_p'm] 但没有 [WARNING][fail][errs][ORA-][abort][corrupt][bad][not complete]' > $log_dir/DBCHK_ORA_CRSDLOGERROR_RES.out;
					cat $v_logname|wc -l > $log_dir/crsdtotalline.log;

				else
					echo "0";
					echo '正常 [阀值='$v_p'm]' > $log_dir/DBCHK_ORA_CRSDLOGERROR_RES.out;
					cat $v_logname|wc -l > $log_dir/crsdtotalline.log;

				fi

			fi

	rm -f $log_dir/errorb.log;


		fi

	else
		echo "1";
		echo "未找到crsd.log,请在[V_ORA_HEA_CRSDLOGPATH]阀值中定义其路径" >$log_dir/DBCHK_ORA_CRSDLOGERROR_RES.out;
	fi

else
	echo "1";
	echo "未找到crsd.log,请在[V_ORA_HEA_CRSDLOGPATH]的阀值定义其路径" >$log_dir/DBCHK_ORA_CRSDLOGERROR_RES.out;
fi




#echo $?;


#print result
cat $log_dir/${filename%%.sh}.out

exit 0
