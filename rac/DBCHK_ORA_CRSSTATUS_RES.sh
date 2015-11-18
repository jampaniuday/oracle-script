#!/usr/bin/env bash
#************************************************#
# 文件名：DBCHK_ORA_CRSSSTATUS.sh            #
# 作  者：ycl                            #
# 日  期：2015年 09月24日                        #
# 功  能：检查RAC crs组件状态    #
# 复核人：                                       #
#************************************************#
#脚本描述
#keys:name|crs组件名称|string,type|类型|string,target|目标|string,status|状态|string,host|节点|string
#describe:检查RAC crs组件状态
#threshold:
#stype:list
#version:g.0.1

#参数定义
LANG=en_US.utf8
basepath=$(dirname $0)
tmpfile="/tmp/$0.$$"

#命令输出
which crs_stat >/dev/null
if [ $? -eq 0 ];then
crs_stat -t|sed 1,2d|awk '{printf "name=\"%s\" type=\"%s\" target=\"\" status=\"%s\" host=\"%s\"\n",$1,$2,$3,$4,$5}'
fi

exit 0
