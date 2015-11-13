#!/usr/bin/env bash
#************************************************#
# 文件名：DBCHK_ORA_SEQUENCEVALUE.sh            #
# 作  者：ycl                            #
# 日  期：2015年 09月24日                        #
# 功  能： 单个session 占用 pga大小查询#
# 复核人：                                       #
#************************************************#
#脚本描述
#keys:sessionid|session标示|string,serialnum|serial#标示|string,pgamem|pga使用量|int
#describe:单个session 占用 pga大小查询 ;
#threshold:
#stype:list
#version:g.0.1

#参数定义
LANG=en_US.utf8
basepath=$(dirname $0)
tmpfile="/tmp/$0.$$"

#阈值默认 100 M
_DEFAULT=100
: ${P:=$_DEFAULT}

#调用sqlplus 库脚本
sqlplus -S "/as sysdba" 1>&2 2>/dev/null <<EOF
 @${basepath}/../sqllib/pgaofsession.sql $tmpfile $P
EOF

#output
[ -f $tmpfile ] && (cat $tmpfile ; rm $tmpfile)
