#!/usr/bin/env bash
#************************************************#
# 文件名：DBCHK_ORA_RECIVETIME.sh            #
# 作  者：ycl                            #
# 日  期：2015年 09月24日                        #
# 功  能：#
# 复核人：                                       #
#************************************************#
#脚本描述
#keys:instancename|实例名称|string,name|名称|string,value|值|string
#describe:
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
 @${basepath}/../sqllib/receivetime.sql $tmpfile
EOF

#output
[ -f $tmpfile ] && (cat $tmpfile ; rm $tmpfile)
