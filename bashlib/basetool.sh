function tempFile()
{
  cat /dev/urandom | head -1 | md5sum | head -c 8
}

function run()
{
  #调用sqlplus 库脚本
  sqlplus -S "/as sysdba" 1>&2 2>/dev/null <<EOF
  @${basepath}/../sqllib/$1 $tmpfile
EOF
}
