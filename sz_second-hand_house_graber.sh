#!/bin/bash

url=http://zjj.sz.gov.cn/ris/bol/szfdc/EsSource.aspx
__EVENTTARGET=AspNetPager1
scriptManager2="updatepanel2|${__EVENTTARGET}"
__EVENTARGUMENT=
__LASTFOCUS=
__VIEWSTATE=
__VIEWSTATEGENERATOR=
__VIEWSTATEENCRYPTED=
__EVENTVALIDATION=
tep_name=
ddlPageCount=20

totalEntry=
entryCounter=0
totalEntrySelector="div.titebox.right span.f14.left"
houseTableSelector="table.table.ta-c.bor-b-1.table-white"
tmp=
logFile=graber_`date +%F_%R_%S`.log
entryFile="total.entry"
dingding="https://oapi.dingtalk.com/robot/send?access_token=02aea34eb941523a5eb7035f2e97fa978fe345844ff2f3410901d35a5e267161"

date > "$entryFile"

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
  totalEntry=`echo "$tmp" | hxselect "$totalEntrySelector" \
    | w3m -dump -cols 2000 -T 'text/html' | tr -cd [0-9]`
  echo  "$tmp" |  hxselect "table.table.ta-c.bor-b-1.table-white" \
    | w3m -dump -cols 2000 -T 'text/html' | sed -n "1p" > "$logFile"
  updateParameters "$tmp"
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



