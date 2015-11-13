#!/bin/sh
#############################################################
###Write by liuwen 2012-11-26
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


resulta=0

for i in `cat -n $log_dir/oracount.list|awk '{print $1}'`
do
v_para=`cat $log_dir/oracount.list|head \`echo -$i\`|tail -1`
username=`echo $v_para|awk '{print $1}'`
sid=`echo $v_para|awk '{print $2}'`;

#chown $username $log_dir/healthcheckparainstance;
#tmp_dir=$log_dir/healthcheckparainstance;

#su - $username -c "export ORACLE_SID=$sid;sh $sh_dir/sqloracle_instancegroup.sql">$log_dir/abc.log;
#rm $log_dir/abc.log;
#su - $username -c "export ORACLE_SID=$sid;sh $sh_dir/sqloracle_parainstancegroup.sql">$log_dir/abc.log;
#rm $log_dir/abc.log;
#查看RAC集群的节点数
#add oracle priv
chown $username $tmp_dir
[ -f $tmp_dir/DBCHK_ORA_VERSION_RES2.out ] && rm -f $tmp_dir/DBCHK_ORA_VERSION_RES2.out
[ -f $tmp_dir/DBCHK_ORA_VERSION_RES3.out ] && rm -f $tmp_dir/DBCHK_ORA_VERSION_RES3.out
#su oracle,exec sql
su - $username 2>&1 1>/dev/null <<EOF
export ORACLE_SID=$sid;
sqlplus "/as sysdba";
set linesize 300;
set heading off;
set feedback off;
set pagesize 10000
SET SQLPROMPT "SQL>";
spool $tmp_dir/DBCHK_ORA_PARAINSTANCE2.out;
select 'INSTANCE='||instance_name||','||value AA from gv\$parameter a,gv\$instance b where name='instance_groups' and a.INST_ID=b.INST_ID order by 1;
spool off;
spool $tmp_dir/DBCHK_ORA_PARAINSTANCE3.out;
select 'PARA='||value AA from gv\$parameter where name='parallel_instance_group' order by value;
spool off;
quit;
EOF


cat $tmp_dir/DBCHK_ORA_PARAINSTANCE2.out|grep -v AA|grep  INSTANCE|awk -F= '{print $2}'>$tmp_dir/n.log
#按照集群的节点数来做循环
	for i in `cat -n $tmp_dir/n.log|awk '{print $1}'`
	do
	   cat $tmp_dir/DBCHK_ORA_PARAINSTANCE2.out|grep -v AA| grep INSTANCE|awk -F= '{print $2}'>$tmp_dir/tmp1.out;
	   cat $tmp_dir/DBCHK_ORA_PARAINSTANCE3.out|grep -v AA| grep PARA|awk -F= '{print $2}'>$tmp_dir/tmp2.out;
	   #把参数instance_name放入到V_1中
	   v_1=`cat $tmp_dir/tmp1.out|head \`echo -$i\`|tail -1|awk -F , '{print $1}'|sed 's/ //g'`;
	   #把参数instance_name放入到V_2中
	   v_2=`cat $tmp_dir/tmp1.out|head \`echo -$i\`|tail -1|awk -F , '{print $2}'|sed 's/ //g'`;
	   #把参数NODE_BOTH放入到V_3中
	   v_3=`cat $tmp_dir/tmp1.out|head \`echo -$i\`|tail -1|awk -F , '{print $3}'|sed 's/ //g'`;
	   #把参数parallel_instance_group值放到V_4中
	   v_4=`cat $tmp_dir/tmp2.out|head \`echo -$i\`|tail -1|awk '{print $1}'|sed 's/ //g'`;

	if [[ -z $v_2 ]];then
		v_2=a
		resulta=`echo \`expr $resulta + 1\``
	fi
	if [[ -z $v_3 ]];then
		v_3=c
		resulta=`echo \`expr $resulta + 1\``
	fi

	if [[ $v_2 = 'node_01' && $v_3 = 'node_both' || $v_2 = 'node_02' && $v_3 = 'node_both' ]]
	then
		  echo '数据库实例'$v_1': 参数instance_groups正常' >> $log_dir/DBCHK_ORA_PARAINSTANCE_RES.out;

	else

	#echo "Non-Compliant";
	resulta=`echo \`expr $resulta + 1\``
	echo "数据库实例"$v_1": 不正常,请查看参数instance_groups" >> $log_dir/DBCHK_ORA_PARAINSTANCE_RES.out;
	fi

	if [[ -z $v_4 ]]
	then
	v_4=d
	resulta=`echo \`expr $resulta + 1\``
	fi


	if [[ $v_4 = 'node_01' || $v_4 = 'node_02' ]]
	  then
			  echo '数据库实例'$v_1': 参数parallel_instance_group正常' >> $log_dir/DBCHK_ORA_PARAINSTANCE_RES.out;
	  else
			  resulta=`echo \`expr $resulta + 1\``
			  echo "数据库实例"$v_1": 不正常,请查看参数parallel_instance_group" >> $log_dir/DBCHK_ORA_PARAINSTANCE_RES.out;
	fi
	done
done
rm -rf $tmp_dir;


if [ $resulta -ne 0 ];then
	echo "$NonCompliant";
else
	echo "$Compliant";
fi

#print result
cat $log_dir/${filename%%.sh}.out

exit 0


