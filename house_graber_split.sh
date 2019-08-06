#!/bin/bash

#array of followers
if (( $# != 1 )); then
exit 1
fi

followers=($1)
totalEntry=`bash sz_second-hand_house_total_entry.sh`
if (( $? != 0 )); then
exit 1
fi

stepLength=0
stepLength=$(( totalEntry % ${#followers[*]} == 0 ? totalEntry / ${#followers[*]} : totalEntry / ${#followers[*]} + 1 ))

start=1
end=0
for (( i = 0; i < ${#followers[*]}; i++ )); do
  ((end = start + stepLength))
  if (( end > (totalEntry + 1) )); then
   (( end = totalEntry + 1 ))
  fi
  echo ${followers[$i]} $start $end
  (( start = end ))
done