#!/usr/bin/env bash
#************************************************#
# 文件名：DBCHK_ORA_ROWMIGRATION.sh            #
# 作  者：ycl                            #
# 日  期：2015年 09月24日                        #
# 功  能：行迁移到多个数据块查询    #
# 复核人：                                       #
#************************************************#
#脚本描述
#keys:owner|用户|string,tablename|表名称|string,numrows|行数|int,avgrowlen|平均行长度|int,chainpercent|迁移比例|int
#describe:行迁移到多个数据块查询;
#threshold:
#stype:list
#version:g.0.1

#参数定义
LANG=en_US.utf8
basepath=$(dirname $0)
tmpfile="/tmp/$0.$$"

#阈值默认 20
_DEFAULT=20
: ${P:=$_DEFAULT}

#调用sqlplus 库脚本
sqlplus -S "/as sysdba" 1>&2 2>/dev/null <<EOF
 @${basepath}/../sqllib/rowchained.sql $tmpfile $P
EOF

#output
[ -f $tmpfile ] && (cat $tmpfile ; rm $tmpfile)
