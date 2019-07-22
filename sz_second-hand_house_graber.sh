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
ddlPageCount=

totalPage=`cat total.page`
newTotalPage=
totalPageSelector="div.titebox.right span.f14.left"
houseTableSelector="table.table.ta-c.bor-b-1.table-white"
tmp=

updateParameters()
{
__VIEWSTATE=`echo "$tmp" | hxselect "#__VIEWSTATE" \
  | hxpipe | grep "Avalue"  | cut -d " " -f3` 
__VIEWSTATEGENERATOR=`echo "$tmp" | hxselect "#__VIEWSTATEGENERATOR" \
  | hxpipe | grep "Avalue"  | cut -d " " -f3`
__EVENTVALIDATION=`echo "$tmp" | hxselect "#__EVENTVALIDATION" \
  | hxpipe | grep "Avalue"  | cut -d " " -f3` 
ddlPageCount=`echo "$tmp" | hxselect "option[selected]" \
  | hxpipe | grep "Avalue"  | cut -d " " -f3`
}

init()
{
  tmp=`curl -s "$url" | hxnormalize -x` 
  newTotalPage=`echo "$tmp" | hxselect "$totalPageSelector" \
    | w3m -dump -cols 2000 -T 'text/html' | tr -cd [0-9]`
  echo  "$tmp" |  hxselect "table.table.ta-c.bor-b-1.table-white" \
    | w3m -dump -cols 2000 -T 'text/html'
  updateParameters "$tmp"
}

init

data="--data-urlencode"
method="-X POST"
head="--header Content-Type:application/x-www-form-urlencoded"
option="-s"
for i in `seq 2 $newTotalPage`; do
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
  | w3m -dump -cols 2000 -T 'text/html' | sed -n '2, $p'
updateParameters "$tmp"
done

echo $newTotalPage > total.page

