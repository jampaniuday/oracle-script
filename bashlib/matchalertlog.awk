BEGIN{
  flag=0
}

{
  if ($0 ~ /Tue Jan 27 12:43:10 2015/)
     flag=1
  else
     getline

  /error/ {printf "errorkey=%s,message=%s","error",$0}
}
