#!/usr/bin/env bash
#************************************************#
# 文件名：DBCHK_ORA_UNDOCNT.sh            #
# 作  者：ycl                            #
# 日  期：2015年 09月24日                        #
# 功  能：查询history_undo的UNXPSTEALCNT,UNXPBLKRELCNT,UNXPBLKREUCNT,EXPSTEALCNT,EXPBLKRELCNT,EXPBLKREUCNT,MAXQUERYLEN
# 复核人：                                       #
#************************************************#
#脚本描述
#keys:name|组件名称|string,total|总大小|int,maxvalueofweek|最大使用量|int
#describe:临时表空间利用率
#threshold:
#stype:list
#version:g.0.1

#参数定义
LANG=en_US.utf8
basepath=$(dirname $0)
bname=$(basename $0)
tmpfile="/tmp/${bname}.$$"

#阈值默认 100 M
#_DEFAULT=100
#: ${P:=$_DEFAULT}

#调用sqlplus 库脚本
sqlplus -S "/as sysdba" 1>&2 2>/dev/null <<EOF
 @${basepath}/../sqllib/undohistorystat.sql $tmpfile
EOF

#output
[ -f $tmpfile ] && (cat $tmpfile ; rm $tmpfile)
