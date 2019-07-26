#!/bin/bash 

taskName1="sz_second-hand_house_graber.sh"
taskLog1="total.entry"
task1RestartMsg="grab task exit unexpectly, restart!"

taskName2="sz_second-hand_house_verify.sh"
taskLog2="house.verify"
task2RestartMsg="verify task exit unexpectly, restart!"

internal=30
while [ 1 ] ; do
isTask1Alive=`ps -efl | grep "$taskName1" | grep -v grep | wc -l`
if [ $isTask1Alive -eq 0 ]; then
    exitCode=`sed '$p' -n "$taskLog1" | cut -d " " -f1`
    if [ $exitCode -ne 0 ]; then
        ./post_dingding_msg.sh "$task1RestartMsg" 
        nohup ./$taskName1 -c > grab.log 2>&1 & 
    fi
fi
isTask2Alive=`ps -efl | grep "$taskName2" | grep -v grep | wc -l`
if [ $isTask2Alive -eq 0 ]; then
    exitCode=`sed '$p' -n "$taskLog2" | cut -d " " -f1`
    opt=`sed '$p' -n "$taskLog2" | cut -d " " -f3`
    if [ $exitCode -ne 0 ]; then
        ./post_dingding_msg.sh "$task2RestartMsg" 
        nohup ./$taskName2 -c "$opt" > grab.log 2>&1 & 
    fi
fi
sleep $internal
done