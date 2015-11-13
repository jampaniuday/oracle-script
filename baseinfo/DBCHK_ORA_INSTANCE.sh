#!/bin/sh
#############################################################
###Write by YCL 2012/8/14
###This script is a health check script of oracle database
###排除用户指定的instance，不对其检查
#############################################################

#参数定义
LANG=en_US.utf8

#get oracle instances,and up and down

#from /etc/oratab
# /usr/yunji/.idcos/oracleinstances.json
# {
# instance1:{
#   "oraclehome":"",
#   "user":"",
#   "status":""
#},
# instance2:{
#   "oraclehome":"",
#   "user":"",
#   "status":""
#},
# }
}
cat <<EOF > /usr/yunji/.idcos/oraint.log
ps -ef |grep ora_smon |grep -v grep|awk  '{printf "user=\"%s\",instname=\"%s\"\n",$1,substr($NF,10)}'
EOF
