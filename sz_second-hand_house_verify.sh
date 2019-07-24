#!/bin/bash

url=http://zjj.sz.gov.cn/ris/szfdc/MLS/Index.aspx
__VIEWSTATE=
__VIEWSTATEGENERATOR=
__VIEWSTATEENCRYPTED=
__EVENTVALIDATION=
txtCode=$1
checkCode=
BtCheck="核对"

cookie="verify.cookie"
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
}

init()
{
  tmp=`curl -c "$cookie" -s "$url" | hxnormalize -x` 
  updateParameters "$tmp"
  curl -b "$cookie" -o "$safecodeFile" -s "$safecodeUrl"
  safecode=`./baidu_ocr.sh -f $safecodeFile -l 0`
}

init

data="--data-urlencode"
method="-X POST"
head="--header Content-Type:application/x-www-form-urlencoded"
option="-s"
tmp=`curl $option $head $method   \
         $data "__VIEWSTATE=$__VIEWSTATE" \
         $data "__VIEWSTATEGENERATOR=$__VIEWSTATEGENERATOR" \
         $data "__VIEWSTATEENCRYPTED=$__VIEWSTATEENCRYPTED" \
         $data "__EVENTVALIDATION=$__EVENTVALIDATION" \
         $data "txtCode=$txtCode" \
         $data "checkCode=$checkCode" \
         $data "BtCheck=$BtCheck" "$url" | hxnormalize -x`
echo  "$tmp" 
updateParameters "$tmp"




