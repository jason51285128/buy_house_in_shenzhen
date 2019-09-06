#!/bin/bash
if (( $# != 1 )); then
exit 1
fi

PWD=$(cd "$(dirname "$0")";pwd)
srcData=($1)
lock=3
exec 3>"$PWD/writelock"

#fuction definition
szSecondHandHouseListDataWash()
{
  msg="`./send_ts.sh` start sync second_hand house list database..."
  echo $msg
  ./post_dingding_msg.sh "$msg"

  #preprocess...
  step1In=`./uuid.sh`
  flock $lock
  cp "$szSecondHandHouseListOrigin" "$step1In"
  flock -u $lock

  #step1: padding phone number
  exec 4<"$step1In"
  step1Out=`./uuid.sh`
  exec 5>"$step1Out"
  lineindex=0
  line=
  while ((1)); do
    read -u 4
    if (( $? != 0 )); then
      break
    fi
    if [ -z "$REPLY" ]; then
      continue
    fi
    ((lineindex++))
    if (( lineindex % 2 == 1 )); then
      line=$REPLY
    else
      phoneNumber=`echo "$REPLY" | tr -cd [0-9]` 
      if [ -z "$phoneNumber" ]; then
        phoneNumber="\\N"
      fi
      echo "$line $phoneNumber" >& 5
    fi
  done
  exec 4>&-
  exec 5>&-
  rm -f $step1In

  #step2: Deduplication
  step2Out=`./uuid.sh`
  tmp=`./uuid.sh`
  awk '!a[$0]++' "$step1Out" > "$tmp"
  awk '!a[$2]++' "$tmp" > "$step2Out" 
  rm -f "$step1Out" "$tmp"
  
  #step3 process diff
  ./diff_process.sh "$step2Out"  
  if (( $? != 0 )); then
    msg="`./send_ts.sh` sync second_hand house list database failed!"
  else
    msg="`./send_ts.sh` sync second_hand house list database success!"
    rm -f "$step2Out"
  fi
  echo "$msg"
  ./post_dingding_msg.sh "$msg"
}

defaultWash()
{
  return 0
}
#fuction definition end

declare -a lastModify
tsn=
tsl=`date +%s`
sleepInterval=10
taskInterval=60
szSecondHandHouseListOrigin="sz_second-hand_house_list.origin"
while ((1)); do
  tsn=`date +%s`
  if (( tsn - tsl < taskInterval )); then
    sleep $sleepInterval
    continue
  fi
  tsl=$tsn

  for(( i = 0; i < ${#srcData[*]}; i++ )); do
    flock $lock
    tmp=`stat -c %Y ${srcData[$i]}`
    flock -u $lock
    if [ "${lastModify[$i]}" != "$tmp" ]; then
      case ${srcData[$i]} in
        "$szSecondHandHouseListOrigin")
          szSecondHandHouseListDataWash
        ;;
        ?)
          defaultWash
        ;;
      esac
      lastModify[$i]="$tmp"
    fi
  done
done