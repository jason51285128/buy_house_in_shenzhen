#!/bin/bash

dingding="https://oapi.dingtalk.com/robot/send?access_token=02aea34eb941523a5eb7035f2e97fa978fe345844ff2f3410901d35a5e267161"
curl -s  "$dingding" \
   -H 'Content-Type: application/json' \
   -d "{\"msgtype\": \"text\", \"text\": {\"content\": \"$1\"}}"