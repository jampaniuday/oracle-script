#!/usr/bin/env bash
#************************************************#
# 文件名：DBCHK_ORA_LOGSTATUS.sh            #
# 作  者：ycl                            #
# 日  期：2015年 09月24日                        #
# 功  能：查询日志文件状态     #
# 复核人：                                       #
#************************************************#
#脚本描述
#keys:groupnum|日志文件组号|int,logfilename|日志文件名称|string,logsize|日志文件大小|int,logstatus|日志文件状态|string|例如：null
#describe:controlfile 状态查询
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
 @${basepath}/../sqllib/logfilestatus.sql $tmpfile
EOF

#output
[ -f $tmpfile ] && (cat $tmpfile ; rm $tmpfile)
