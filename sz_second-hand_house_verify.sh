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
errMsg="verify task exit unexpectly!"
successMsg="verify task finish!"

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
  ./post_dingding_msg.sh "$errMsg"
  exit 1
fi 

cp "$taskLog" "${taskLog}.backup"
date > "$taskLog"
grabOut="$1"
for txtCode in `awk '/[0-9]{12}/ {if (NF < 9) {print $6}  else {print $7}}' "$grabOut"`; do
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
./post_dingding_msg.sh  "$errMsg"
echo "1 $txtCode" >> "$taskLog"
exit 1
fi
echo  "$tmp" | hxselect "table.table.verify-table.table-white.mb20" \
  | w3m -dump -cols 2000 -T 'text/html' > "$taskOut/$txtCode"
updateParameters "$tmp"
if [ "$?" != "0" ]; then
  ./post_dingding_msg.sh "$errMsg"
  exit 1
fi
done

echo "0 $txtCode" >> "$taskLog" 
date >> "$taskLog"
./post_dingding_msg.sh  "$successMsg"
rm -rf "${taskLog}.backup"
