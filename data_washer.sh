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

  #step4: Deduplication
  step4Out=`./uuid.sh`
  touch $step4Out
  for line in `awk '/[0-9]{12}/ {print "\""$0"\""}' "$step3Out" `; do
    houseCode=`echo "$line" | awk '{print $7}'`
    isExist=`grep "$houseCode" "$step4Out"`
    if [ -z "$isExist" ]; then
      echo "$line" | cut -d "\"" -f2 >> $step4Out
    fi
  done
  rm -f "$step3Out"

  #step5: compare-looking for add and delete
  step5Out="graber_leader.sql"
  cat /dev/null > $step5Out
  database="sz_house_list"
  table="second_hand"
  host="94.191.116.177"
  port="9224"
  pw="buyhouse@sz"
  echo "USE $database;" >> "$step5Out"
  for line in `awk '/[0-9]{12}/ {print "\""$0"\""}' "$step4Out" `; do
    houseCode=`echo "$line" | awk '{print $7}'`
    isExist=`grep "$houseCode" "$graberLeaderOutLastTime"`
    if [ -z "$isExist" ]; then
      xiangmumingchen=`echo "$line" | cut -d "\"" | awk '{print $1}'` 
      hetongliushuihao=`echo "$line" | cut -d "\"" | awk '{print $2}'`
      qushu=`echo "$line" | cut -d "\"" | awk '{print $3}'`
      mainjipingfangmi=`echo "$line" | cut -d "\"" | awk '{print $4}'`
      yongtu=`echo "$line" | cut -d "\"" | awk '{print $5}'`
      louceng=`echo "$line" | cut -d "\"" | awk '{print $6}'`
      fangyuanbianma=`echo "$line" | cut -d "\"" | awk '{print $7}'`
      dailizhongjie=`echo "$line" | cut -d "\"" | awk '{print $8}'`
      faburiqi=`echo "$line" | cut -d "\"" | awk '{print $9}'`
      lianxidianhua=`echo "$line" | cut -d "\"" | awk '{print $10}'`
      zhuangtai=`echo "$line" | cut -d "\"" | awk '{print $11}'`
      shouchuriqi=`echo "$line" | cut -d "\"" | awk '{print $12}'`
      echo  "INSERT INTO $table VALUES (\'$xiangmumingchen\', \'$hetongliushuihao\', \'$qushu\', \'$mainjipingfangmi\', \'$yongtu\', \'$louceng\', \'$fangyuanbianma\', \'$dailizhongjie\', \'$faburiqi\', \'$zhuangtai\', \'$shouchuriqi\');" >> "$step5Out"
    fi
  done
  date=`./send_ts.sh | cut -d " " -f1`
  for line in `awk '/[0-9]{12}/ {print "\""$0"\""}' "$graberLeaderOutLastTime" `; do
    houseCode=`echo "$line" | awk '{print $7}'`
    isExist=`grep "$houseCode" "$step4Out"`
    if [ -z "$isExist" ]; then
      fangyuanbianma=`echo "$line" | cut -d "\"" | awk '{print $7}'`
      zhuangtai='已售'
      shouchuriqi="$date"
      echo  "UPDATE $table SET zhuangtai=$zhuangtai, shouchuriqi=$shouchuriqi WHERE fangyuanbianma=$fangyuanbianma;" >> "$step5Out"
    fi
  done
  mysql -h$host -P$port -uroot -p$pw -e "$step5Out"
  rm -f $step5Out
  mv "$step4Out" $step5Out
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

