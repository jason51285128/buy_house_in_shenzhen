#!/bin/bash

if (( $# < 1 )); then
exit 1
fi

url=http://zjj.sz.gov.cn/ris/szfdc/MLS/Index.aspx
__VIEWSTATE=
__VIEWSTATEGENERATOR=
__VIEWSTATEENCRYPTED=
__EVENTVALIDATION=
txtCode="$1"
checkCode=
BtCheck="核对"
scriptName="sz_second-hand_house_price"
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
    $?=1
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
  echo "1 0"
  rm -f $cookie $safecodeFile
  exit
fi
value=`echo  "$tmp" | hxselect "table.table.verify-table.table-white.mb20" \
  | w3m -dump -cols 2000 -T 'text/html' `
if [[ "$value" == "查无资料或者该房源已经失效" ]]; then
  echo "0 invalid"
else
  price=`echo "$value" | awk '/意向价格（万元）/ {print $3}' | cut -d "：" -f2`
  echo "0 $price"
fi

rm -f $cookie $safecodeFile