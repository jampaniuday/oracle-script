#!/usr/bin/env bash
#************************************************#
# 文件名：DBCHK_ORA_LOGSWITCH.sh            #
# 作  者：ycl                            #
# 日  期：2015年 09月24日                        #
# 功  能：检查数据库redo logfile 切换次数/每小时      #
# 复核人：                                       #
#************************************************#
#脚本描述
logswitchtime="2015110411" count="1"
#keys:logswitchtime|日志切换点|string,count|切换次数|int
#describe:检查数据库 失效的job
#threshold:
#stype:list
#version:g.0.1

#参数定义
LANG=en_US.utf8
basepath=$(dirname $0)
bname=$(basename $0)
tmpfile="/tmp/${bname}.$$"

#调用sqlplus 库脚本
sqlplus -S "/as sysdba" 1>&2 2>/dev/null <<EOF
 @${basepath}/../sqllib/logfileswitch.sql $tmpfile
EOF

#output
[ -f $tmpfile ] && (cat $tmpfile ; rm $tmpfile)
