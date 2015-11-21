#!/usr/bin/env bash
#************************************************#
# 文件名：DBCHK_ORA_NOBACKUPFILE.sh            #
# 作  者：ycl                            #
# 日  期：2015年 09月24日                        #
# 功  能：一周没有备份的表空间     #
# 复核人：                                       #
#************************************************#
#脚本描述
#keys:nobkdatafile|没有备份的数据库文件|string
#describe:单表上索引关联表列数量过多；联合索引,关联的表列数量;
#threshold:
#stype:list
#version:g.0.1

#参数定义
LANG=en_US.utf8
basepath=$(dirname $0)
bname=$(basename $0)
tmpfile="/tmp/${bname}.$$"

#阈值默认 7
_DEFAULT=7
: ${W:=$_DEFAULT}

#调用sqlplus 库脚本
sqlplus -S "/as sysdba" 1>&2 2>/dev/null <<EOF
 @${basepath}/../sqllib/nobackupfile.sql $tmpfile $W
EOF

#output
[ -f $tmpfile ] && (cat $tmpfile ; rm $tmpfile)
