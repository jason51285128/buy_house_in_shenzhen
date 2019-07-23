#!/bin/bash

url=http://zjj.sz.gov.cn/ris/szfdc/MLS/Index.aspx
__VIEWSTATE=
__VIEWSTATEGENERATOR=
__VIEWSTATEENCRYPTED=
__EVENTVALIDATION=
txtCode=$1
checkCode=
BtCheck="核对"

img=
imgurl=http://zjj.sz.gov.cn/ris/szfdc/MLS/
imgSelector="img.CodeImg"

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
  tmp=`curl -s "$url" | hxnormalize -x` 
  updateParameters "$tmp"
  echo "$tmp" | hxselect "$imgSelector" | hxpipe |  grep 
}

init

data="--data-urlencode"
method="-X POST"
head="--header Content-Type:application/x-www-form-urlencoded"
option="-s"
i=1
while [[ $entryCounter -lt $totalEntry ]]; do
tmp=`curl $option $head $method   \
         $data "__EVENTTARGET=$__EVENTTARGET" \
         $data "scriptManager2=$scriptManager2" \
         $data "__EVENTARGUMENT=$i" \
         $data "__LASTFOCUS=$__LASTFOCUS" \
         $data "__VIEWSTATE=$__VIEWSTATE" \
         $data "__VIEWSTATEGENERATOR=$__VIEWSTATEGENERATOR" \
         $data "__VIEWSTATEENCRYPTED=$__VIEWSTATEENCRYPTED" \
         $data "__EVENTVALIDATION=$__EVENTVALIDATION" \
         $data "tep_name=$tep_name" \
         $data "ddlPageCount=$ddlPageCount" "$url" | hxnormalize -x`
echo  "$tmp" |  hxselect "table.table.ta-c.bor-b-1.table-white" \
  | w3m -dump -cols 2000 -T 'text/html' | sed -n '2, $p' >> "$logFile"
updateParameters "$tmp"
i=`expr $i + 1`
entryCounter=`expr $entryCounter + $ddlPageCount`
done

echo $totalEntry >> "$entryFile"
echo "i=$i" >> "$entryFile"
echo "entryCounter=$entryCounter" >> "$entryFile"
date >> "$entryFile"

curl -s  "$dingding" \
   -H 'Content-Type: application/json' \
   -d '{"msgtype": "text", 
        "text": {
             "content": "grab done!"
        }
      }'



