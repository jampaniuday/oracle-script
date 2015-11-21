#!/usr/bin/env bash
#************************************************#
# 文件名：DBCHK_ORA_SYSTBS.sh            #
# 作  者：ycl                            #
# 日  期：2015年 09月24日                        #
# 功  能：查询是否非系统用户，占用system表空间       #
# 复核人：                                       #
#************************************************#
#脚本描述
#keys:owner|用户|string,segment|表名称|string
#describe:查询是否非系统用户，占用system表空间
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
 @${basepath}/../sqllib/showsystbs.sql $tmpfile
EOF

#output
[ -f $tmpfile ] && (cat $tmpfile ; rm $tmpfile)
