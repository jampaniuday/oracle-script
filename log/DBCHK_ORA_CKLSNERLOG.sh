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
bname=$(basename $0)
tmpfile="/tmp/${bname}.$$"
datetime=`date "+%F %H:%M"`

#add listener log
lsnrlog=$(lsnrctl status |grep network|awk '{print $2}')
size=`du -sk $lsnrlog|cut -f1`
cat <<EOF
timestamp="${datetime}" path="$lsnrlog" size="${size}"
EOF
