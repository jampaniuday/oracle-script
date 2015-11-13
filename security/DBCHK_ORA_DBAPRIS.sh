#!/usr/bin/env bash
#************************************************#
# 文件名：DBCHK_ORA_DBAPRIS.sh            #
# 作  者：ycl                            #
# 日  期：2015年 09月24日                        #
# 功  能：查询非系统用户，有dba角色的用户    #
# 复核人：                                       #
#************************************************#
#脚本描述
#keys:grantee|用户|string,privilege|权限|string,adminoption|ADMIN|string
#describe:查询非系统用户，具体grantee 权限的用户
#threshold:
#stype:list
#version:g.0.1

#参数定义
LANG=en_US.utf8
basepath=$(dirname $0)
tmpfile="/tmp/$0.$$"

#调用sqlplus 库脚本
sqlplus -S "/as sysdba" 1>&2 2>/dev/null <<EOF
 @${basepath}/../sqllib/dbaroleprivs.sql $tmpfile
EOF

#output
[ -f $tmpfile ] && (cat $tmpfile ; rm $tmpfile)
