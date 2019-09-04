#!/bin/bash

dingding="https://oapi.dingtalk.com/robot/send?access_token=6edf6aab371de1c06eac24c9c2a64e239b1f7de63e62840419c7aac93bc3c0e4"
curl -s  "$dingding" \
   -H 'Content-Type: application/json' \
   -d "{\"msgtype\": \"text\", \"text\": {\"content\": \"$1\"}}" >/dev/null 2>&1