#!/bin/bash

PWD="$(cd "$(dirname "$0")"; pwd)"

followerList="follower.list"
wdir="zhangchen/bhisz"

exec 3<"$followerList"
while ((1)); do
  read -u 3
  if (( $? != 0 )); then
    break
  fi
  host=`echo "$REPLY" | cut -d " " -f1`
  port=`echo "$REPLY" | cut -d " " -f2`
  account=`echo "$REPLY" | cut -d " " -f3`
  pw=`echo "$REPLY" | cut -d " " -f4`
  echo `./send_ts.sh` "stop follower in $host $port $account $pw"    
  sshpass -p "$pw" ssh -o StrictHostKeyChecking=no $account "killall -w graber_follower.sh; killall -w ncat" 
  echo 
done