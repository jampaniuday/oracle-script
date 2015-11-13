#!/usr/bin/env bash
#************************************************#
# 文件名：DBCHK_ORA_TEMPSIZEFORSQL.sh            #
# 作  者：ycl                            #
# 日  期：2015年 09月24日                        #
# 功  能：需要大量排序的sql语句       #
# 复核人：                                       #
#************************************************#
#脚本描述
#keys:owner|用户|string,sqlcontent|sql语句|string,block|占用块大小|int
#describe:需要大量排序的sql语句，阈值500m
#threshold:_DEFAULT=500
#stype:list
#version:g.0.1

#参数定义
LANG=en_US.utf8
basepath=$(dirname $0)
tmpfile="/tmp/$0.$$"

#阈值定义 500m
_DEFAULT=500
: ${BGSORT:=$_DEFAULT}

#调用sqlplus 库脚本
sqlplus -S "/as sysdba" 1>&2 2>/dev/null <<EOF
 @${basepath}/../sqllib/showbigsort.sql $tmpfile $BGSORT
EOF

#output
[ -f $tmpfile ] && (cat $tmpfile ; rm $tmpfile)
