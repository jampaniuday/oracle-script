#!/usr/bin/env bash
#************************************************#
# 文件名：DBCHK_ORA_VERSION.sh            #
# 作  者：ycl                            #
# 日  期：2015年 09月24日                        #
# 功  能：查询数据库组件版本       #
# 复核人：                                       #
#************************************************#
#脚本描述
#keys:componetname|名称|string,version|版本|string
#describe:查询数据库组件版本
#threshold:
#stype:list
#version:g.0.1

#参数定义
LANG=en_US.utf8
basepath=$(dirname $0)
tmpfile="/tmp/$0.$$"

#调用sqlplus 库脚本
sqlplus -S "/as sysdba" 1>&2 2>/dev/null <<EOF
 @${basepath}/../sqllib/showversion.sql $tmpfile
EOF

#output
[ -f $tmpfile ] && (cat $tmpfile ; rm $tmpfile)
