#!/usr/bin/env bash
#************************************************#
# 文件名：DBCHK_ORA_PGAPERCET.sh            #
# 作  者：ycl                            #
# 日  期：2015年 09月24日                        #
# 功  能：pga 使用情况    #
# 复核人：                                       #
#************************************************#
#脚本描述
#keys:nowsize|pga当前大小|string,defaultsize|pga设置大小|int,maxsize|历史最大值|int
#describe:PGA 使用情况查询;
#threshold:
#stype:list
#version:g.0.1

#参数定义
LANG=en_US.utf8
basepath=$(dirname $0)
bname=$(basename $0)
tmpfile="/tmp/${bname}.$$"

#阈值默认 7
#_DEFAULT=7
#: ${W:=$_DEFAULT}

#调用sqlplus 库脚本
sqlplus -S "/as sysdba" 1>&2 2>/dev/null <<EOF
 @${basepath}/../sqllib/pgastate.sql $tmpfile
EOF

#output
[ -f $tmpfile ] && (cat $tmpfile ; rm $tmpfile)
