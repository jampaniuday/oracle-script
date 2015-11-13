#!/usr/bin/env bash
#************************************************#
# 文件名：SYSCHK_LINUX_INVALIDINDEX.sh            #
# 作  者：ycl                            #
# 日  期：2015年 09月24日                        #
# 功  能：检查数据库失效的索引       #
# 复核人：                                       #
#************************************************#
#脚本描述
DBMS_OUTPUT.PUT_LINE('owner="'||j.owner||'" indexname="'||j.index_name||'" tablename="'||j.table_name||'" status="'||j.status||'"');
#keys:owner|用户|string,indexname|索引名称|string,tablename|表名称|string,status|状态|string
#describe:检查数据库失效的索引
#threshold:
#stype:list
#version:g.0.1

#参数定义
LANG=en_US.utf8
basepath=$(dirname $0)
tmpfile="/tmp/$0.$$"

#调用sqlplus 库脚本
sqlplus -S "/as sysdba" 1>&2 2>/dev/null <<EOF
 @${basepath}/../sqllib/invalidindex.sql $tmpfile
EOF

#output
[ -f $tmpfile ] && (cat $tmpfile ; rm $tmpfile)
