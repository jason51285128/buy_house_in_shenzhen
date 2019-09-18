#!/bin/bash

dingding="https://oapi.dingtalk.com/robot/send?access_token=a50c97b545405e06399feed5edbcc68743c24ce0c58e4a60fc9a68399ffc3d7d"
curl -s  "$dingding" \
   -H 'Content-Type: application/json' \
   -d "{\"msgtype\": \"text\", \"text\": {\"content\": \"$1\"}}" >/dev/null 2>&1