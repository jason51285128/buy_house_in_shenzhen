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

houseTableSelector="table.table.ta-c.bor-b-1.table-white"
tmp=
scriptName="sz_second-hand_house_graber"
cookie=${scriptName}_`date +%N`
cookie=`echo "$cookie" | md5sum | cut -d " " -f1`
if (( $# < 2 )); then
exit 1
fi
start=$1
end=$2
if (( end <= start )); then
exit 1
fi

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
option="-b $cookie -s"
for (( i = $start; i < $end; i++ )); do 
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
if [[ "$?" != "0" || -z "$tmp" ]]; then
  sleep 30
  init
  ((i--))
  continue
fi
updateParameters "$tmp"
tmp=`echo "$tmp" | hxnormalize -x`
echo  "$tmp" |  hxselect "table.table.ta-c.bor-b-1.table-white" \
  | w3m -dump -cols 2000 -T 'text/html' | sed -n '2, $p'
done

echo EOF
rm -f "$cookie"
