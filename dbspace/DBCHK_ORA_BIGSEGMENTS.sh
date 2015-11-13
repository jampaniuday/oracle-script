#!/usr/bin/env bash
#************************************************#
# 文件名：DBCHK_ORA_BIGSEGMENTS.sh            #
# 作  者：ycl                            #
# 日  期：2015年 09月24日                        #
# 功  能：查询超过10g，但没有分区的表       #
# 复核人：                                       #
#************************************************#
#脚本描述
#keys:owner|用户|string,tablename|表名称|string,bytes|大小|int
#describe:查询超过10g，但没有分区的表
#threshold:
#stype:list
#version:g.0.1

#参数定义
LANG=en_US.utf8
basepath=$(dirname $0)
tmpfile="/tmp/$0.$$"

#阈值定义
_DEFAULT=10
: ${BGTB:=$_DEFAULT}

#调用sqlplus 库脚本
sqlplus -S "/as sysdba" 1>&2 2>/dev/null <<EOF
 @${basepath}/../sqllib/bigtables.sql $tmpfile $BGTB
EOF

#output
[ -f $tmpfile ] && (cat $tmpfile ; rm $tmpfile)
