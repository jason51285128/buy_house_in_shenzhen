#!/bin/bash

PWD=$(cd "$(dirname "$0")";pwd)

#configuration
conf="leader_election.json"
electionTimeout=3
leardHeartBeatTimeout=3
broker="0.0.0.0 8080"
myid="0.0.0.0:8081"
stateTable=(0 0 1 0 0 0 2 0 2 1 2 1)

#const
MSG_TYPE_LEADER_HEART_BEAT=0

FOLLOWER=0
LEADER=1
CANDIDATE=2

#variable
term=1
state=$FOLLOWER
curLeader=
leaderHeartbeatCounter=0
ageCounter=0


help()
{
    cat <<  HERE
    usage: ./leader_election.sh -f config_file.json
      -f: specify configuration file, default "leader_election.json"
HERE
}

parseConfig()
{
  electionTimeout=`cat "$conf" | jq .electionTimeout | cut -d "\"" -f2`
  leardHeartBeatTimeout=`cat "$conf" | jq .leardHeartBeatTimeout| cut -d "\"" -f2`
  broker=`cat "$conf" | jq .broker | cut -d "\"" -f2`
  myid=`cat "$conf" | jq .myid | cut -d "\"" -f2`
}

leaderHeartbeatHandle()
{
  leader=$1
  leaderTerm=$2

  flock $lock
  ((leaderHeartbeatCounter++))
  if [[ "$curLeader" != "$leader" ]]; then
    curLeader="$leader"
  fi
  if (( $leaderTerm > $term )); then
    term=$leaderTerm
  fi
  case $state in
    $FOLLOWER)
    ;;
    $LEADER)
      echo "receive leader heartbeat when state=LEADER"
      exit 1
    ;;
    $CANDIDATE)
      state=$FOLLOWER
    ;;
    ?)
    ;;
  esac 
  flock -u $lock
}

leaderHeartbeatLostHandle()
{
  flock $lock
  if (($leaderHeartbeatCounter == 0)); then
    state=$CANDIDATE
  
  fi
  flock -u $lock
}

while getopts "f:h" arg
do
    case $arg in
    f)
    conf=$OPTARG
    parseConfig
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

# create msg fifo
msginFile=/tmp/`date +%s`
msgin=3
msgoutFile=/tmp/`date +%s`
msgout=4
mkfifo $msginFile
mkfifo $msgoutFile
exec $msgin<>$msginFile
exec $msgout<>$msgoutFile
rm -f $msginFile $msgoutFile

#crate lock
lockFile=/tmp/`date +%s`
lock=5
exec $lock>$lockFile

#start msg center
{nc $broker 0 <& $msgout 1 >& $msgin 2 > /dev/null } &

#recevie msg
#msgType  msgSender  term
{
  while ((1)); do
    read -u $msginFd -t $leardHeartBeatTimeout msgType msgSender term
    if (( $? != 0)); then
      continue
    fi
    case $msgType in
      $MSG_TYPE_LEADER_HEART_BEAT)
      ;;
      ?)
      continue
      ;;
    esac
  done
} &

#age....
while ((1)); do
  sleep 1
  (($ageCounter++))
  if (( $ageCounter >= $leardHeartBeatTimeout)); then
  fi
done







