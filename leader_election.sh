#!/bin/bash

PWD=$(cd "$(dirname "$0")";pwd)

#configuration
conf="leader_election.json"
agePeriod=1000  #老化周期，单位为毫秒
heartbeatThreshold=5 #leader心跳报文发送阈值，表示多少倍老化周期
checkThreshold=15 #检测定时器阈值，表示多少倍老化周期，3倍心跳报文阈值
broker="0.0.0.0 8080"
myAddr="0.0.0.0:8081"
myId=0
curLeaderAddr=
curLeaderId=0 

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
}

onLeaderHeartbeatPktRcve()
{
  flock $lock
  read -u $receiveStatus leaderHeartbeatPkgCounter leaderid leadAddr selfRecommendationPkgCounter recommenderId recommendAddr 
  ((leaderHeartbeatPkgCounter++, leaderid=senderId, leadAddr=senderAddr))
  echo "$leaderHeartbeatPkgCounter $leaderid $leadAddr $selfRecommendationPkgCounter $recommenderId $recommendAddr" >& $receiveStatus 
  flock -u $lock
}

onSelfRecommendationPktRcve()
{
  flock $lock
  read -u $receiveStatus leaderHeartbeatPkgCounter leaderid leadAddr selfRecommendationPkgCounter recommenderId recommendAddr 
  if (( senderId > recommenderId )); then
    ((selfRecommendationPkgCounter++, recommenderId=senderId, recommendAddr=senderAddr))
    echo "$leaderHeartbeatPkgCounter $leaderid $leadAddr $selfRecommendationPkgCounter $recommenderId $recommendAddr" >& $receiveStatus 
  fi
  flock -u $lock 
}

ActionDefault()
{
  return 0
}

Action00010()
{
  #发送自荐报文
  ts=`date +%Y-%m-%d-%H-%M-%S`  
  echo "$MSG_TYPE_SELF_RECOMMENDATION $myAddr $myId $ts" >& $msgout
}

Action01010()
{
  #将leader置为自己
  curLeaderAddr="$myAddr"
  ((curLeaderId=myId))
}

Action01011()
{
  #将自荐者作为自己的leader
  curLeaderAddr="$recommendAddr"
  (( curLeaderId=recommenderId ))
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

#crate lock
lockFile=/tmp/`date +%N`
lock=3
exec 3>$lockFile

# create msg fifo
msginFile=/tmp/`date +%N`
msgoutFile=/tmp/`date +%N`
mkfifo $msginFile
mkfifo $msgoutFile

# create receive status table
#format: leaderHeartbeatPktCounter leaderid leadAddr selfRecommendationPkgCounter recommenderId recommendAddr
receiveStatusTable="lerst" # leader election receive status table
touch $receiveStatusTable

#start msg center
{ 
  exec 4<$msgoutFile
  exec 5>$msginFile
  rm -f $msginFile $msgoutFile
  ncat $broker 0<&4 1>&3 2>/dev/null
} &

#recevie msg
#msgType  senderAddr senderId sendts msgBody
{
  msgType=
  senderAddr=
  senderId=
  sendts=
  msgBody=

  exec 4<$msginFile
  exec 5<>$receiveStatusTable
  receiveStatus=5

  while ((1)); do
    read -u 4 msgType senderAddr senderId sendts msgBody 
    if (( $? != 0 )); then
      exit 0
    fi
    case $msgType in
      $MSG_TYPE_LEADER_HEART_BEAT)
        onLeaderHeartbeatPktRcve
      ;;
      $MSG_TYPE_SELF_RECOMMENDATION)
        onSelfRecommendationPktRcve
      ;;
      ?)
      continue
      ;;
    esac
  done
} &

#open msgout pipe
msgout=4
exec 4>$msgoutFile

#open receive status table for RW
receiveStatus=5
exec 5<>$receiveStatusTable

#signal handle
trap "exec 4>&-; exec 5>&-; rm -f $receiveStatusTable; exit 0" TERM INT


#age....
tsn=0 #当前时刻，以ms为单位
tsl=`getMsTs` #上一个时刻，以ms为单位
while ((1)); do
  tsn=`getMsTs`
  if (( tsn - tsl < agePeriod )); then
    sleep 0.1 
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
    read -u $receiveStatus leaderHeartbeatPkgCounter leaderid leadAddr selfRecommendationPkgCounter recommenderId recommendAddr 
    if (( leaderHeartbeatPkgCounter > 0 )); then
      (( c0=1, curLeaderId=leaderid ))
      curLeaderAddr=$leadAddr
    fi
    if (( selfRecommendationPkgCounter > 0 && recommenderId > myId )); then
      ((c2=1))
    fi
    echo "0 0 0  0 0 0" >& $receiveStatus 
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
      echo "$MSG_TYPE_LEADER_HEART_BEAT $myAddr $myId $ts" >& $msgout
    fi
  fi

  if (( ++heartbeatTimer, heartbeatTimer >= heartbeatThreshold )); then
    ((heartbeatTimer=0))
    if (( state == LEADER )); then
      ts=`date +%Y-%m-%d-%H-%M-%S`
      echo "$MSG_TYPE_LEADER_HEART_BEAT $myAddr $myId $ts" >& $msgout
    fi
  fi
  echo $oldstate $c0 $c1 $c2 $state `date +%Y-%m-%d-%H-%M-%S`
done
