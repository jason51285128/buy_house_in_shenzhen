#!/bin/bash

url=http://zjj.sz.gov.cn/ris/szfdc/MLS/Index.aspx
__VIEWSTATE=
__VIEWSTATEGENERATOR=
__VIEWSTATEENCRYPTED=
__EVENTVALIDATION=
txtCode=
checkCode=
BtCheck="核对"

if (( $# < 1 )); then
exit 1
fi
grabOut="$1"
scriptName="sz_second-hand_house_verify"
cookie=${scriptName}_`date +%N`
cookie=`echo "$cookie" | md5sum | cut -d " " -f1`
safecodeFile="safecode.jpg"
safecodeUrl=http://zjj.sz.gov.cn/ris/szfdc/MLS/SafeCode.aspx
safecode=

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
  if [[ "$?" != "0" || -z "$safecode" ]]; then
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
  exit 1
fi 

tmpout=${scriptName}_`date +%N`
tmpout=`echo "$tmpout" | md5sum | cut -d " " -f1`
echo "[" > $tmpout

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
rm -f $tmpout
exit 1
fi
value=`echo  "$tmp" | hxselect "table.table.verify-table.table-white.mb20" \
  | w3m -dump -cols 2000 -T 'text/html' `
value=`echo "$value" | base64 | sed ":a;N;s/\n/\*/g;ta"`
echo "{\"key\": \"$txtCode\", \"value\": \"$value\"}," >> $tmpout  
updateParameters "$tmp"
if [ "$?" != "0" ]; then
  rm -f $tmpout
  exit 1
fi
done

rm -f "$cookie"
echo "{\"key\": \"\", \"value\": \"\"}" >> $tmpout   
echo "]" >> $tmpout
cat $tmpout | jq .
rm -f $tmpout