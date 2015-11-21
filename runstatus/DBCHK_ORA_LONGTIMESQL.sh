#!/usr/bin/env bash
#************************************************#
# 文件名：DBCHK_ORA_LONGTIMERSQL.sh            #
# 作  者：ycl                            #
# 日  期：2015年 09月24日                        #
# 功  能：检查数据库长时间运行的sql      #
# 复核人：                                       #
#************************************************#
#脚本描述
#keys:optname|操作名称|string,username|执行用户|string,sqladdress|sql语句地址|string
#describe:检查数据库长时间运行的sql
#threshold:
#stype:list
#version:g.0.1

#参数定义
LANG=en_US.utf8
basepath=$(dirname $0)
bname=$(basename $0)
tmpfile="/tmp/${bname}.$$"

#阈值默认 3600s
_DEFAULT=3600
: ${LT:=$_DEFAULT}

#调用sqlplus 库脚本
sqlplus -S "/as sysdba" 1>&2 2>/dev/null <<EOF
 @${basepath}/../sqllib/longtimerunsql.sql $tmpfile $LT
EOF

#output
[ -f $tmpfile ] && (cat $tmpfile ; rm $tmpfile)
