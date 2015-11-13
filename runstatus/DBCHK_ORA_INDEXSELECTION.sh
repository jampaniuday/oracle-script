#!/usr/bin/env bash
#************************************************#
# 文件名：SYSCHK_LINUX_INDEXSELECTION.sh            #
# 作  者：ycl                            #
# 日  期：2015年 09月24日                        #
# 功  能：索引区分度查询                     #
# 复核人：                                       #
#************************************************#
#脚本描述
#keys:indexname|索引名称|string,tablename|表名称|string,owner|用户|string,numrows|行数|int,distinctkeys|区分值|int,selection|选择度|int
#describe:索引区分度查询
#threshold:
#stype:list
#version:g.0.1

#参数定义
LANG=en_US.utf8
basepath=$(dirname $0)
tmpfile="/tmp/$0.$$"

#阈值默认20
_DEFAULT=20
: ${FILTER:=$_DEFAULT}


#调用sqlplus 库脚本
sqlplus -S "/as sysdba" 1>&2 2>/dev/null <<EOF
 @${basepath}/../sqllib/indexefficient.sql $tmpfile $FILTER
EOF

#output
[ -f $tmpfile ] && (cat $tmpfile ; rm $tmpfile)
