#!/usr/bin/env bash
#************************************************#
# 文件名：DBCHK_ORA_DUMPDIRSIZE.sh            #
# 作  者：ycl                            #
# 日  期：2015年 09月24日                        #
# 功  能：查询'background_dump_dest','core_dump_dest','user_dump_dest','audit_file_dest' 目录空间大小      #
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

#调用sqlplus 库脚本
sqlplus -S "/as sysdba" 1>&2 2>/dev/null <<EOF
 @${basepath}/../sqllib/showdumpfile.sql $tmpfile
EOF

for l in `cat $tmpfile`
do
	name=`echo $l|cut -d= -f1`
	path=`echo $l|cut -d= -f2`
	size=`du -sk $path|cut -f1`
	cat <<EOF
name="$name" path="$path" size="$size"
EOF
done

#clean tmpfile
[ -f $tmpfile ] && rm $tmpfile
