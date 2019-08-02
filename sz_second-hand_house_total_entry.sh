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
totalEntrySelector="div.titebox.right span.f14.left"

scriptName="sz_second-hand_house_total_entry"
cookie=${scriptName}_`date +%N`
cookie=`echo "$cookie" | md5sum | cut -d " " -f1`

tmp=`curl -c "$cookie" -s "$url" | hxnormalize -x` 
totalEntry=`echo "$tmp" | hxselect "$totalEntrySelector" \
  | w3m -dump -cols 2000 -T 'text/html' | tr -cd [0-9]`
rm -f "$cookie"
echo $totalEntry