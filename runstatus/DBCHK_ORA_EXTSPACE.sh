#!/usr/bin/env bash
#************************************************#
# 文件名：DBCHK_ORA_EXTSPACE.sh            #
# 作  者：ycl                            #
# 日  期：2015年 09月24日                        #
# 功  能：      #
# 复核人：                                       #
#************************************************#
#脚本描述
#keys:owner|用户名|string,tablename|数据表|string,constraintname|外键名称|string,cols|列名称|多个列名称通过下划线分割
#describe:检查数据库 失效的job
#threshold:
#stype:list
#version:g.0.1

#参数定义
LANG=en_US.utf8
basepath=$(dirname $0)
tmpfile="/tmp/$0.$$"

#调用sqlplus 库脚本
sqlplus -S "/as sysdba" 1>&2 2>/dev/null <<EOF
 @${basepath}/../sqllib/extentfreespace.sql $tmpfile
EOF

#output
[ -f $tmpfile ] && (cat $tmpfile ; rm $tmpfile)
