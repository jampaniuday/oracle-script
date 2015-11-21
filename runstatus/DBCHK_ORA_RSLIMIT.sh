#!/usr/bin/env bash
#************************************************#
# 文件名：DBCHK_ORA_RSLIMIT.sh            #
# 作  者：ycl                            #
# 日  期：2015年 09月24日                        #
# 功  能：数据库资源限制使用情况查询   #
# 复核人：                                       #
#************************************************#
#脚本描述
#keys:resourcename|资源名称|string,currentutilization|当前值|int,initialallocation|初始值|int,maxutilization|最大值|int,limit_value|上限制值|int
#describe:数据库资源限制使用情况查询 ;
#threshold:
#stype:list
#version:g.0.1

#参数定义
LANG=en_US.utf8
basepath=$(dirname $0)
bname=$(basename $0)
tmpfile="/tmp/${bname}.$$"

#阈值默认 20
#_DEFAULT=20
#: ${P:=$_DEFAULT}

#调用sqlplus 库脚本
sqlplus -S "/as sysdba" 1>&2 2>/dev/null <<EOF
 @${basepath}/../sqllib/resourcelimit.sql $tmpfile
EOF

#output
[ -f $tmpfile ] && (cat $tmpfile ; rm $tmpfile)
