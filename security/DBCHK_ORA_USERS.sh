#************************************************#
# 文件名：DBCHK_ORA_DBAUSERS.sh            #
# 作  者：ycl                            #
# 日  期：2015年 09月24日                        #
# 功  能：查询数据库用户属性    #
# 复核人：                                       #
#************************************************#
#脚本描述
#keys:username|用户|string,userid|用户唯一标示|string,status|状态|string,expirydate|过期时间|string,lockdate|锁日期|string,defaulttablespace|默认表空间|string,profile|配置文件|string
#describe:查询数据库用户属性
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
 @${basepath}/../sqllib/dbausers.sql $tmpfile
EOF

#output
[ -f $tmpfile ] && (cat $tmpfile ; rm $tmpfile)
