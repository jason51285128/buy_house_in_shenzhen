#!/bin/bash

PWD="$(cd "$(dirname "$0")"; pwd)"

followerList="follower.list"
action="./szshhg.sh"
followers=
out="sz_second-hand_house_list.origin"


exec 3<"$followerList"
while ((1)); do
  read -u 3
  if (( $? != 0 )); then
    break
  fi
  host=`echo "$REPLY" | cut -d " " -f1`
  port=`echo "$REPLY" | cut -d " " -f2`
  followers="${followers}$host:$port "
done

echo `./send_ts.sh` " start leader $action \"$followers\" $out"
nohup ./graber_leader.sh "$action" "$followers" "$out" > graber_leader.log 2>&1 &