#!/usr/bin/env bash
#************************************************#
# 文件名：DBCHK_ORA_CONFILESTATE.sh            #
# 作  者：ycl                            #
# 日  期：2015年 09月24日                        #
# 功  能：controlfile 状态查询       #
# 复核人：                                       #
#************************************************#
#脚本描述
#keys:name|controlfile名称|string,status|状态|string
#describe:controlfile 状态查询
#threshold:
#stype:list
#version:g.0.1

#参数定义
LANG=en_US.utf8
basepath=$(dirname $0)
bname=$(basename $0)
tmpfile="/tmp/${bname}.$$"

#调用sqlplus 库脚本
sqlplus -S "/as sysdba" 1>&2 2>/dev/null <<EOF
 @${basepath}/../sqllib/controlfile.sql $tmpfile
EOF

#output
[ -f $tmpfile ] && (cat $tmpfile ; rm $tmpfile)
