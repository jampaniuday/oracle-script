#!/usr/bin/env bash
#************************************************#
# 文件名：SYSCHK_LINUX_INDEXBLEVEL.sh            #
# 作  者：ycl                            #
# 日  期：2015年 09月24日                        #
# 功  能：查询数据库索引blevel值      #
# 复核人：                                       #
#************************************************#
#脚本描述
#keys:indexname|索引名称|string,indextype|索引类型|string,tablename|表名称|string,owner|用户|string,blevel|blevel级别|int
#describe:查询数据库索引blevel值
#threshold:
#stype:list
#version:g.0.1

#参数定义
LANG=en_US.utf8
basepath=$(dirname $0)
tmpfile="/tmp/$0.$$"

#阈值定义
_DEFAULT=4
: ${BLEVEL:=$_DEFAULT}

#调用sqlplus 库脚本
sqlplus -S "/as sysdba" 1>&2 2>/dev/null <<EOF
 @${basepath}/../sqllib/indexblevel.sql $tmpfile $BLEVEL
EOF

#output
[ -f $tmpfile ] && (cat $tmpfile ; rm $tmpfile)
