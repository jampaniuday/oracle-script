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
which ocrcheck >/dev/null
if [ $? -eq 0 ];then
cat ocrcheck.txt |awk 'BEGIN{FS=":"}
/Version/ {printf "version=\"%s\" ",gsub(/[ ]+/,"",$2)}
/Total space/ {printf "Totalspace=\"%s\" ",gsub(/[ ]+/,"",$2)}
/Used space/ {printf "usedspace=\"%s\" ",gsub(/[ ]+/,"",$2)}
/Available space/{printf "availablespace=\"%s\" ",gsub(/[ ]+/,"",$2)}'

fi

:<<BLOCK
cat <<EOF | awk 'BEGIN{FS=":"} /Version/ {printf "version=\"%s\" ",gsub(/[ ]+/,"",$2)} /Total space/ {printf "Totalspace=\"%s\" ",gsub(/[ ]+/,"",$2)} /Used space/ {printf "usedspace=\"%s\" ",gsub(/[ ]+/,"",$2)} /Available space/{printf "availablespace=\"%s\" ",gsub(/[ ]+/,"",$2)}'
Status of Oracle Cluster Registry is as follows :
	 Version                  :          3
	 Total space (kbytes)     :     262120
	 Used space (kbytes)      :       2876
	 Available space (kbytes) :     259244
	 ID                       : 2086263606
	 Device/File Name         :       +crs
                                    Device/File integrity check succeeded

                                    Device/File not configured

                                    Device/File not configured

                                    Device/File not configured

                                    Device/File not configured

	 Cluster registry integrity check succeeded

	 Logical corruption check succeeded
EOF
BLOCK
exit 0
