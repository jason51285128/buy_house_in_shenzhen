#!/bin/bash
if (( $# != 1 )); then
exit 1
fi

PWD=$(cd "$(dirname "$0")";pwd)
srcData=($1)
lock=3
exec 3>"$PWD/writelock"

#fuction definition
graberLeaderDataWash()
{
  step1In=`./uuid.sh`
  flock $lock
  cp "$graberLeaderOut" "$step1In"
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

   #setp2: handle missing field: louceng zhuangtai shouchuriqi
  exec 4<$step1Out
  step2Out=`./uuid.sh`
  exec 5>$step2Out
  while ((1));do
    read -u 4
    if (( $? != 0 )); then
      break
    fi
    state="在售"
    date='\\N'
    line=`echo "$REPLY" | awk '{if ( NF < 10 ) {$5=$5" \\\N";$NF=$NF" '"$state"' '"$date"'"} else {$NF=$NF" '"$state"' '"$date"'"} print $0 }'`
    echo "$line" >& 5
  done
  exec 4>&-
  exec 5>&-
  rm -f $step1Out 

  #step3: conv space to tab
  step3Out="$step2Out"
  sed -i 's/\s\+/\t/g' "$step3Out"

  afterwash="graber_leader_out.aw"
  mv $step3Out $afterwash
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
graberLeaderOut="graber_leader.out"
graberLeaderOutLastTime="graber_leader.last"
verifierOut="verifier.out"
verifierOutLastTime="verifier.last"
locationQuerierOut="location_querier.out"
locationQuerierLastTime="location_querier.last"
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
        "$graberLeaderOut")
          graberLeaderDataWash
        ;;
        "$verifierOut")
          defaultWash
        ;;
        "$locationQuerierOut")
          defaultWash
        ;;
        ?)
          defaultWash
        ;;
      esac
      lastModify[$i]="$tmp"
    fi
  done

done

