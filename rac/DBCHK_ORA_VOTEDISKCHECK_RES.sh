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
which crsctl >/dev/null
if [ $? -eq 0 ];then
crsctl query css votedisk|sed 1,2d|awk '{if (NF == 5) printf "num=\"%s\" uuid=\"%s\" filename=\"%s\" status=\"%s\" dgroup=\"%s\"\n",$1,$3,$4,$2,$5}'
fi

:<<BLOCK
cat <<EOF |awk '{if (NF == 5) printf "num=\"%s\" uuid=\"%s\" filename=\"%s\" status=\"%s\" dgroup=\"%s\"\n",$1,$3,$4,$2,$5}'
 1. ONLINE   9031ad352ab34f2ebf3c93e0652c1cab (/dev/asm-diske) [CRS]
Located 1 voting disk(s).
EOF
BLOCK
exit 0
