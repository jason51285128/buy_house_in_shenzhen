#!/bin/bash

url=http://api.map.baidu.com/place/v2/search
key=
tag=`echo -n "住宅区" | od -t x1 -A n -w1000|tr " " "%" | tr [a-z] [A-Z]`
city_limit=true
page_size=1
region=`echo -n "深圳" | od -t x1 -A n -w1000|tr " " "%"| tr [a-z] [A-Z]`
output=json
ak=VrazWXUeiaOslNyhNUhRMTaGOeDXPw5a

taskOut=location_db
taskLog=query.location

exitCode0="0 finish!"
exitCode1="1 parameter parse failed in continue mode!"
exitCode2="2 Call BAIDUmap failed!"
exitMsg="query location exit:"

mode="$1"
grabOut="$2"
lastHouseCode=
if [ "$mode" = "-c" ]; then
lastHouseCode=`cat "$taskLog" | cut -d " " -f2`
grabOut=`cat "$taskLog" | cut -d " " -f3`
if [ -z "$lastHouseCode" ]; then
./post_dingding_msg.sh "$exitMsg $exitCode1"
exit 1
fi
if [ -z "$grabOut" ]; then
./post_dingding_msg.sh "$exitMsg $exitCode1"
exit 1
fi
fi

getLocation()
{
    key=`echo -n "$1" | od -t x1 -A n -w1000|tr " " "%" | tr [a-z] [A-Z]`
    curl -s "$url?query=$key&tag=$tag&city_limit=$city_limit&page_size=$page_size&region=$region&output=$output&ak=$ak" 
}

cp -f "$taskLog" "$taskLog.backup"
date > "$taskLog"
mkdir -p $taskOut
for name_tab_code in `awk '/[0-9]{12}/ {if (NF < 9) {print $1"."$6}  else {print $1"."$7}}' "$grabOut"`; do
    houseName=`echo -n "$name_tab_code" | cut -d "."  -f1`
    houseCode=`echo -n "$name_tab_code" | cut -d "." -f2`
    if [ "$mode" -c ]; then
      if [ "$houseCode" != "$lastHouseCode" ]; then
      continue
      fi
    fi
    location=`getLocation $houseName` 
    if [ -z "$location" ]; then
      ./post_dingding_msg.sh "$exitMsg $exitCode2"
      echo "1 $houseCode $grabOut" >> "$taskLog" 
      exit 1
    fi
    echo "$location" > "$taskOut/$houseCode"
done

echo "0 $houseCode $grabOut" >> "$taskLog" 
date >> "$taskLog"
rm -f "$taskLog.backup"
./post_dingding_msg.sh "$exitMsg $exitCode0"
exit