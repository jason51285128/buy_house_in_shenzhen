#!/bin/bash

url=http://zjj.sz.gov.cn/ris/szfdc/MLS/Index.aspx
__VIEWSTATE=
__VIEWSTATEGENERATOR=
__VIEWSTATEENCRYPTED=
__EVENTVALIDATION=
txtCode=
checkCode=
BtCheck="核对"

cookie="verify.cookie"
safecodeFile="safecode.jpg"
safecodeUrl=http://zjj.sz.gov.cn/ris/szfdc/MLS/SafeCode.aspx
safecode=
taskOut="verify_db"
taskLog="house.verify"

updateParameters()
{
__VIEWSTATE=`echo "$tmp" | hxselect "#__VIEWSTATE" \
  | hxpipe | grep "Avalue"  | cut -d " " -f3` 
__VIEWSTATEGENERATOR=`echo "$tmp" | hxselect "#__VIEWSTATEGENERATOR" \
  | hxpipe | grep "Avalue"  | cut -d " " -f3`
__EVENTVALIDATION=`echo "$tmp" | hxselect "#__EVENTVALIDATION" \
  | hxpipe | grep "Avalue"  | cut -d " " -f3` 
  curl -b "$cookie" -o "$safecodeFile" -s "$safecodeUrl"
  if [ "$?" != "0" ]; then
    return
  fi
  safecode=`./baidu_ocr.sh -f $safecodeFile -l 0 | sed '$p' -n |  cut -d "\"" -f2`
  if [ "$?" != "0" ]; then
    return
  fi 
}

init()
{
  tmp=`curl -c "$cookie" -s "$url" | hxnormalize -x` 
  updateParameters "$tmp"
}

init
if [ "$?" != "0" ]; then
  return
fi 

grabOut="$1"
for txtCode in `grep $grabOut "[0-9]\{12\}" | awk '{print $7}'`; do
data="--data-urlencode"
method="-X POST"
head="--header Content-Type:application/x-www-form-urlencoded"
option="-s -b $cookie"
tmp=`curl $option $head $head1 $method   \
         $data "__VIEWSTATE=$__VIEWSTATE" \
         $data "__VIEWSTATEGENERATOR=$__VIEWSTATEGENERATOR" \
         $data "__VIEWSTATEENCRYPTED=$__VIEWSTATEENCRYPTED" \
         $data "__EVENTVALIDATION=$__EVENTVALIDATION" \
         $data "txtCode=$txtCode" \
         $data "checkCode=$safecode" \
         $data "BtCheck=$BtCheck" "$url" | hxnormalize -x`
if [ -z "$tmp" ]; then
echo "1 $txtCode" > "$taskLog"
exit 1
fi
echo  "$tmp" | hxselect "table.table.verify-table.table-white.mb20" \
  | w3m -dump -cols 2000 -T 'text/html' > "$taskOut/$txtCode"
updateParameters "$tmp"
done




