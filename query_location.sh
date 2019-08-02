#!/bin/bash

url=https://restapi.amap.com/v3/place/text
keywords=
city_limit=true
page_size=1
region=0755
output=json
ak=40bfa5e93c6f9b3f7f2d7eb90f3e3c6c

location=
successStatus=1

if (( $# < 1 )); then
exit 1
fi
grabOut="$1"

getLocation()
{
    keywords=`echo -n "$1" | od -t x1 -A n -w1000|tr " " "%" | tr [a-z] [A-Z]`
    location=`curl -s "$url?keywords=$keywords&city=$region&types=120000&city_limit=$city_limit&offset=$page_size&output=$output&key=$ak"`
    status=`echo "$location" | jq .status | cut -d "\"" -f2`
    if [ "$status" != "$successStatus" ]; then
      location=
    fi
}

scriptName="query_location"
tmpout=${scriptName}_`date +%N`
tmpout=`echo "$tmpout" | md5sum | cut -d " " -f1`
echo "[" > $tmpout

for name_dot_code in `awk '/[0-9]{12}/ {if (NF < 9) {print $1"."$6}  else {print $1"."$7}}' "$grabOut"`; do
    houseName=`echo -n "$name_dot_code" | cut -d "."  -f1`
    houseCode=`echo -n "$name_dot_code" | cut -d "." -f2`
    getLocation "$houseName" 
    if [ -z "$location" ]; then
      rm -f $tmpout
      exit 1
    fi
    location=`echo "$location" | sed "s/^{/{\"key\":\"$houseCode\",/"`
    location=`echo "$location" | sed "s/$/,/"`
    echo $location >> $tmpout
    sleep 0.1
done

echo "{\"key\": \"\", \"value\": \"\"}" >> $tmpout   
echo "]" >> $tmpout
cat $tmpout | jq .
rm -f $tmpout