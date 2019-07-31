#!/bin/bash

PWD=$(cd "$(dirname "$0")";pwd)

#configuration
conf="leader_election.json"
agePeriod=1000  #老化周期，单位为毫秒
heartbeatThreshold=5 #leader心跳报文发送阈值，表示多少倍老化周期
checkThreshold=15 #检测定时器阈值，表示多少倍老化周期，3倍心跳报文阈值
broker="0.0.0.0 8080"
myAddr="0.0.0.0:8081"
myId=
stateTable=(0 0 1 0 0 0 0 0 
            1 1 2 0 1 1 0 0
            2 2 2 2 2 2 0 0)
actionTable=(ActionDefault ActionDefault Action00010 ActionDefault ActionDefault ActionDefault ActionDefault ActionDefault
             ActionDefault ActionDefault Action01010 Action01011   ActionDefault ActionDefault ActionDefault ActionDefault
             ActionDefault ActionDefault ActionDefault ActionDefault ActionDefault ActionDefault ActionDefault ActionDefault
             )

#const
MSG_TYPE_LEADER_HEART_BEAT=0
MSG_TYPE_SELF_RECOMMENDATION=1

FOLLOWER=0
CANDIDATE=1
LEADER=2

#variable
CheckTimer=0 #检测定时器
heartbeatTimer=0 #心跳定时器
state=$FOLLOWER
RecommenderAddr=
RecommenderId=
msgType=
senderAddr=
senderId=
sendts=
msgBody=

#lock resource
leaderHeartbeatPkgCounter=0
selfRecommendationPkgCounter=0
curLeaderAddr=
curLeaderId=0 

#function definition
help()
{
    cat <<  HERE
usage: ./leader_election.sh -f config_file.json
  -f: specify configuration file, default "leader_election.json"
HERE
}

getMsTs()
{
  ts=`date +%s-%N`
  s=`echo "$ts" | cut -d "-" -f1`
  ns=`echo "$ts" | cut -d "-" -f2`
  echo "$s * 1000 + $ns / 1000000" | bc
}

getMyId()
{
  port=`echo $myAddr | cut -d ":" -f2`
  ip0=`echo $myAddr | cut -d ":" -f1 | cut -d "." -f1`
  ip1=`echo $myAddr | cut -d ":" -f1 | cut -d "." -f2`
  ip2=`echo $myAddr | cut -d ":" -f1 | cut -d "." -f3`
  ip3=`echo $myAddr | cut -d ":" -f1 | cut -d "." -f4`
  echo $(( (ip0 << 19) + (ip1 << 18) + (ip2 << 17) + (ip3 << 16) + port ))
}

parseConfig()
{
  tmp=`cat "$conf" | jq .agePeriod | cut -d "\"" -f2`
  if [ "$tmp" != "null" ]; then
    agePeriod="$tmp"
  fi
  tmp=`cat "$conf" | jq .heartbeatThreshold| cut -d "\"" -f2`
  if [ "$tmp" != "null" ]; then
    heartbeatThreshold="$tmp"
  fi
  tmp=`cat "$conf" | jq .checkThreshold| cut -d "\"" -f2`
  if [ "$tmp" != "null" ]; then
    checkThreshold="$tmp"
  fi
  tmp=`cat "$conf" | jq .broker | cut -d "\"" -f2`
  if [ "$tmp" != "null" ]; then
    broker="$tmp"
  fi
  tmp=`cat "$conf" | jq .myAddr | cut -d "\"" -f2` 
  if [ "$tmp" != "null" ]; then
    myAddr="$tmp"
  fi
  myId=`getMyId`
  RecommenderId=$myId
}

onLeaderHeartbeatPktRcve()
{
  flock $lock
  if [[ "$curLeaderAddr" != "$senderAddr" || (( curLeaderId != senderId )) ]]
  then
    curLeaderAddr="$senderAddr"
    curLeaderId="$senderId"
  fi
  (( leaderHeartbeatPkgCounter++ ))
  flock -u $lock
}

onSelfRecommendationPktRcve()
{
  if (( senderId > RecommenderId )); then
    RecommenderAddr="$senderAddr"
    (( RecommenderId=senderId ))
    flock $lock
    (( selfRecommendationPkgCounter++ ))
    flock -u $lock
  fi
  
}

ActionDefault()
{
  return 0
}

Action00010()
{
  #发送自荐报文
  ts=`date +%Y-%m-%d-%H-%M-%S`  
  echo "$MSG_TYPE_SELF_RECOMMENDATION $myAddr $myId $ts" >> $msgout
}

Action01010()
{
  #将leader置为自己
  flock $lock
  curLeaderAddr="$myAddr"
  curLeaderId="$myId"
  flock -u $lock
}

Action01011()
{
  #将自荐者作为自己的leader
  flock $lock
  curLeaderAddr="$RecommenderAddr"
  (( curLeaderId=RecommenderId ))
  flock -u $lock
}

#start...
while getopts "f:h" arg
do
    case $arg in
    f)
    conf=$OPTARG
    ;;
    h)
    help
    exit 0
    ;;
    ?)
    help
    exit 1
    ;;
    esac
done
parseConfig

# create msg fifo
msginFile=/tmp/`date +%N`
msgin=3
msgoutFile=/tmp/`date +%N`
msgout=4
mkfifo $msginFile
mkfifo $msgoutFile
exec 3<>"$msginFile"
exec 4<>"$msgoutFile"
rm -f $msginFile $msgoutFile
trap "exec 3>&-; exec 4>&-; exit 0" TERM INT

#crate lock
lockFile=/tmp/`date +%N`
lock=5
exec 5>$lockFile

#start msg center
{ 
  ncat $broker 0<&4 1>&3 2>/dev/null
} &

#recevie msg
#msgType  senderAddr senderId sendts msgBody
{
  while ((1)); do
    read -u $msgin msgType senderAddr senderId sendts msgBody 
    case $msgType in
      $MSG_TYPE_LEADER_HEART_BEAT)
      ;;
      $MSG_TYPE_SELF_RECOMMENDATION)
      ;;
      ?)
      continue
      ;;
    esac
  done
} &

#age....
tsn=0 #当前时刻，以ms为单位
tsl=`getMsTs` #上一个时刻，以ms为单位
while ((1)); do
  tsn=`getMsTs`
  if (( tsn - tsl < agePeriod )); then
    sleep 1 
    continue
  fi
  ((tsl=tsn))

  c0=0 #是否收到leader心跳报文
  c1=0 #检测定时器是否超时
  c2=0 #是否收到id更大的节点的自荐报文
  
  if (( ++CheckTimer, CheckTimer >= checkThreshold )); then
    (( c1=1, CheckTimer=0))
  fi
  if ((c1 == 1)); then
    flock $lock
      if (( leaderHeartbeatPkgCounter > 0 )); then
        (( c0=1, leaderHeartbeatPkgCounter=0 ))
      fi
      if (( selfRecommendationPkgCounter > 0 )); then
        ((c2=1, selfRecommendationPkgCounter=0))
      fi
    flock -u $lock
  fi

  ((oldstate=state))  
  key=$(( (state << 3) + (c0 << 2) + (c1 << 1) + $c2 )) 
  state=${stateTable[$key]}
  action=${actionTable[$key]}
  $action
  if (( state != oldstate )); then
    echo "state change! $oldstate $c0 $c1 $c2 $state"
    #切换成leader，快发一帧心跳
    if (( state == LEADER )); then
      ts=`date +%Y-%m-%d-%H-%M-%S`
      echo "$MSG_TYPE_LEADER_HEART_BEAT $myAddr $myId $ts" >> $msgout
    fi
  fi

  if (( ++heartbeatTimer, heartbeatTimer >= heartbeatThreshold )); then
    ((heartbeatTimer=0))
    if (( state == LEADER )); then
      ts=`date +%Y-%m-%d-%H-%M-%S`
      echo "$MSG_TYPE_LEADER_HEART_BEAT $myAddr $myId $ts" >> $msgout
    fi
  fi
  echo $oldstate $c0 $c1 $c2 $state `date +%Y-%m-%d-%H-%M-%S`
done
