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
cookie="graber.cookie"

date > "$entryFile"

updateParameters()
{
lastLine=`echo "$tmp" | sed '$p' -n`
__VIEWSTATE=`echo "$lastLine" | cut -d "|" -f17`
__VIEWSTATEGENERATOR=`echo "$lastLine" | cut -d "|" -f21`
__EVENTVALIDATION=`echo "$lastLine" | cut -d "|" -f29`
}

init()
{
  tmp=`curl -c "$cookie" -s "$url" | hxnormalize -x` 
  totalEntry=`echo "$tmp" | hxselect "$totalEntrySelector" \
    | w3m -dump -cols 2000 -T 'text/html' | tr -cd [0-9]`
  echo  "$tmp" |  hxselect "table.table.ta-c.bor-b-1.table-white" \
    | w3m -dump -cols 2000 -T 'text/html' | sed -n "1p" > "$logFile"
  __VIEWSTATE=`echo "$tmp" | hxselect "#__VIEWSTATE" \
    | hxpipe | grep "Avalue"  | cut -d " " -f3` 
  __VIEWSTATEGENERATOR=`echo "$tmp" | hxselect "#__VIEWSTATEGENERATOR" \
    | hxpipe | grep "Avalue"  | cut -d " " -f3`
  __EVENTVALIDATION=`echo "$tmp" | hxselect "#__EVENTVALIDATION" \
    | hxpipe | grep "Avalue"  | cut -d " " -f3` 
}

init

data="--data-urlencode"
method="-X POST"
head="--header Content-Type:application/x-www-form-urlencoded"
head1="--header X-MicrosoftAjax:Delta=true"
head2="--header Accept:*/*"
head3="--header Accept-Encoding:gzip,deflate"
head4="--header Accept-Language:zh-CN,zh;q=0.9"
head5="--header Cache-Control:no-cache"
head6="--header Connection:keep-alive"
head7="--header User-Agent:Mozilla/5.0%20(Windows%20NT%2010.0;%20WOW64)%20AppleWebKit/537.36%20(KHTML,%20like%20Gecko)%20Chrome/75.0.3770.142%20Safari/537.36"
option="-b $cookie -v"
i=1
while [[ $entryCounter -lt $totalEntry ]]; do
tmp=`curl $option $head $head1 $head2 $head3 $head4 $head5 $head6 $head7 $method   \
         $data "__EVENTTARGET=$__EVENTTARGET" \
         $data "scriptManager2=$scriptManager2" \
         $data "__EVENTARGUMENT=$i" \
         $data "__LASTFOCUS=$__LASTFOCUS" \
         $data "__VIEWSTATE=$__VIEWSTATE" \
         $data "__VIEWSTATEGENERATOR=$__VIEWSTATEGENERATOR" \
         $data "__VIEWSTATEENCRYPTED=$__VIEWSTATEENCRYPTED" \
         $data "__EVENTVALIDATION=$__EVENTVALIDATION" \
         $data "tep_name=$tep_name" \
         $data "ddlPageCount=$ddlPageCount" "$url"`
if [ $? -ne 0 ]; then
echo "exit: $?"
curl -s  "$dingding" \
   -H 'Content-Type: application/json' \
   -d '{"msgtype": "text", 
        "text": {
             "content": "error in grab!"
        }
      }'
exit 1
fi
if [ -z "$tmp" ]; then
echo "exit $?"
curl -s  "$dingding" \
   -H 'Content-Type: application/json' \
   -d '{"msgtype": "text", 
        "text": {
             "content": "error in grab!"
        }
      }'
exit 1
fi
updateParameters "$tmp"
tmp=`echo "$tmp" | hxnormalize -x`
echo $i >> "$logFile"
echo  "$tmp" |  hxselect "table.table.ta-c.bor-b-1.table-white" \
  | w3m -dump -cols 2000 -T 'text/html' | sed -n '2, $p' >> "$logFile"
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