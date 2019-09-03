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
  echo `./send_ts.sh` " start $host $port $account $pw"    
  sshpass -p "$pw" ssh -o StrictHostKeyChecking=no $account "cd $wdir;git reset --hard;git pull origin;chmod +x *.sh;mv sz_second-hand_house_graber.sh szshhg.sh;nohup ./graber_follower.sh $host $port > follower.log 2>&1 &" 
  if (( $? != 0 )); then
    echo `./send_ts.sh` " failed start follower!"
    exit 1
  fi
done

echo `./send_ts.sh` " all followers is started!"