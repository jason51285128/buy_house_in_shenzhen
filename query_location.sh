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
houseName="$1"

getLocation()
{
    keywords=`echo -n "$1" | od -t x1 -A n -w1000|tr " " "%" | tr [a-z] [A-Z]`
    location=`curl -s "$url?keywords=$keywords&city=$region&types=120000&city_limit=$city_limit&offset=$page_size&output=$output&key=$ak"`
    status=`echo "$location" | jq .status | cut -d "\"" -f2`
    if [ "$status" != "$successStatus" ]; then
      location=
    fi
}

getLocation "$houseName" 
if [ -z "$location" ]; then
  echo "1 0"
  exit 1
fi
coordinate=`echo "$location" | jq .pois[0].location | cut -d "\"" -f2`
echo "0 $coordinate"