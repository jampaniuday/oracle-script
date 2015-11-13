#!/usr/bin/env bash
#************************************************#
# 文件名：DBCHK_ORA_DBSTATUS.sh            #
# 作  者：ycl                            #
# 日  期：2015年 09月24日                        #
# 功  能：查询表空间，数据文件状态       #
# 复核人：                                       #
#************************************************#
#脚本描述
#keys:tablespacename|表空间名称|string,dbfilename|数据文件名称|string,dbfilesize|数据文件大小|int,dbfstatus|数据文件状态|string|例如ONLINE、OFFLINE,tbsstatus|表空间状态|string|例如ONLINE、OFFLINE
#describe:controlfile 状态查询
#threshold:
#stype:list
#version:g.0.1

#参数定义
LANG=en_US.utf8
basepath=$(dirname $0)
tmpfile="/tmp/$0.$$"

#调用sqlplus 库脚本
sqlplus -S "/as sysdba" 1>&2 2>/dev/null <<EOF
 @${basepath}/../sqllib/dbfilestate.sql $tmpfile
EOF

#output
[ -f $tmpfile ] && (cat $tmpfile ; rm $tmpfile)
