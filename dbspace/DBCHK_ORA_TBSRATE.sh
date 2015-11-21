#!/usr/bin/env bash
#************************************************#
# 文件名：DBCHK_ORA_TBSRATE.sh            #
# 作  者：ycl                            #
# 日  期：2015年 09月24日                        #
# 功  能：表空间情况查询      #
# 复核人：                                       #
#************************************************#
#脚本描述
#keys:tablespacename|表空间名称|string,sumspace|总大小|string,usedspace|使用量|int,usedrate|使用率|int,freespace|剩余空间|int,segmentmanagement|segment管理|string
#describe:表空间情况查询
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
 @${basepath}/../sqllib/tablespaces.sql $tmpfile
EOF

#output
[ -f $tmpfile ] && (cat $tmpfile ; rm $tmpfile)
