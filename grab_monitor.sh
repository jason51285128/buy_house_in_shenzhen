#!/bin/bash 

taskName1="sz_second-hand_house_graber.sh"
taskLog1="total.entry"
dingding="https://oapi.dingtalk.com/robot/send?access_token=02aea34eb941523a5eb7035f2e97fa978fe345844ff2f3410901d35a5e267161"


internal=30
while [ 1 ] ; do
isTask1Alive=`ps -efl | grep "$taskName1" | grep -v grep | wc -l`
if [ $isTask1Alive -eq 0 ]; then
    exitCode=`sed '$p' -n "$taskLog1" | cut -d " " -f1`
    if [ $exitCode -ne 0 ]; then
        curl -s  "$dingding" \
             -H 'Content-Type: application/json' \
             -d '{"msgtype": "text", 
                  "text": {
                   "content": "grab task exit unexpectly, restart!"
                   }
                }'
        nohup ./$taskName1 -c > grab.log 2>&1 & 
    fi
fi
sleep $internal
done