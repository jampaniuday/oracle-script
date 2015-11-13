#!/usr/bin/env bash
#************************************************#
# 文件名：DBCHK_ORA_SHAREPOOLCHECK.sh            #
# 作  者：ycl                            #
# 日  期：2015年 09月24日                        #
# 功  能： 检查request_failures+ABORTED_REQUESTS参数是否等于0
# 复核人：                                       #
#************************************************#
#脚本描述
#keys:sessionid|session标示|string,serialnum|serial#标示|string,pgamem|pga使用量|int
#describe:检查request_failures+ABORTED_REQUESTS参数是否等于0
#threshold:
#stype:list
#version:g.0.1

#参数定义
LANG=en_US.utf8
basepath=$(dirname $0)
tmpfile="/tmp/$0.$$"

#阈值默认 100 M
#_DEFAULT=100
#: ${P:=$_DEFAULT}

#调用sqlplus 库脚本
sqlplus -S "/as sysdba" 1>&2 2>/dev/null <<EOF
 @${basepath}/../sqllib/sharepoolreserved.sql $tmpfile
EOF

#output
[ -f $tmpfile ] && (cat $tmpfile ; rm $tmpfile)
