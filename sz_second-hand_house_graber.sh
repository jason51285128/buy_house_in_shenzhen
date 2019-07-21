#!/bin/bash

url=http://zjj.sz.gov.cn/ris/bol/szfdc/EsSource.aspx
__EVENTTARGET=AspNetPager1
scriptManager2="updatepanel2|${__EVENTTARGET}"
__EVENTARGUMENT=
__VIEWSTATE=
__VIEWSTATEGENERATOR=
__VIEWSTATEENCRYPTED=
__EVENTVALIDATION=
tep_name=
ddlPageCount=

totalPage=`cat total.page`
totalPageSelector="div.titebox.right span.f14.left"

tmp=`curl -s $url | hxnormalize -x`
newTotalPage=`echo "$tmp" | hxselect "$totalPageSelector" \
  | w3m -dump -cols 2000 -T 'text/html' | tr -cd [0-9]`
__VIEWSTATE=`echo "$tmp" | hxselect "#__VIEWSTATE" \
  | hxpipe | grep "Avalue"  | cut -d " " -f3` 
__VIEWSTATEGENERATOR=`echo "$tmp" | hxselect "#__VIEWSTATEGENERATOR" \
  | hxpipe | grep "Avalue"  | cut -d " " -f3`
__EVENTVALIDATION=`echo "$tmp" | hxselect "#__EVENTVALIDATION" \
  | hxpipe | grep "Avalue"  | cut -d " " -f3` 
ddlPageCount=`echo "$tmp" | hxselect "option[selected]" \
  | hxpipe | grep "Avalue"  | cut -d " " -f3`

echo $newTotalPage 
echo "__EVENTTARGET=$__EVENTTARGET"
echo "scriptManager2=$scriptManager2"
echo "__EVENTARGUMENT=$__EVENTARGUMENT"
echo "__VIEWSTATE=$__VIEWSTATE"
echo "__VIEWSTATEGENERATOR=$__VIEWSTATEGENERATOR"
echo "__VIEWSTATEENCRYPTED=$__VIEWSTATEENCRYPTED"
echo "__EVENTVALIDATION=$__EVENTVALIDATION"
echo "tep_name=$tep_name"
echo "ddlPageCount=$ddlPageCount"

curl  -s --data-urlencode __EVENTTARGET="$__EVENTTARGET" \
         --data-urlencode scriptManager2="$scriptManager2" \
         -data-urlencode __EVENTARGUMENT="$__EVENTARGUMENT" \
         --data-urlencode __VIEWSTATE="$__VIEWSTATE" \
         --data-urlencode __VIEWSTATEGENERATOR="$__VIEWSTATEGENERATOR" \
         --data-urlencode __VIEWSTATEENCRYPTED="$__VIEWSTATEENCRYPTED" \
         --data-urlencode __EVENTVALIDATION="$__EVENTVALIDATION" \
         -data-urlencode tep_name="$tep_name" \
         --data-urlencode ddlPageCount="$ddlPageCount" "$url"



