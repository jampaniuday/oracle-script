#!/usr/bin/env bash
#************************************************#
# 文件名：DBCHK_ORA_DUMPDIRSIZE.sh            #
# 作  者：ycl                            #
# 日  期：2015年 09月24日                        #
# 功  能：查询一定时间区间内产生的归档日志大小，单位 mb/day    #
# 复核人：                                       #
#************************************************#
#脚本描述
#keys:timestamp|时间|string,space|占用空间|int
#describe:查询一定时间区间内产生的归档日志大小，单位 mb/day
#threshold:
#stype:list
#version:g.0.1

#参数定义
LANG=en_US.utf8
basepath=$(dirname $0)
bname=$(basename $0)
tmpfile="/tmp/${bname}.$$"

#阈值定义
_DEFAULT="7"
: ${ERRORLIST:=$_DEFAULT}

#调用sqlplus 库脚本
sqlplus -S "/as sysdba" 1>&2 2>/dev/null <<EOF
 @${basepath}/../sqllib/archivelogsize.sql $tmpfile $day
EOF
