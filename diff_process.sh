#!/bin/bash

PWD="$(cd "$(dirname "$0")"; pwd)"

beforeExit()
{
  rm -f "$tmp" "$newData" "$out" "$oldData" "$diffData"
}

if (( $# != 1 )); then
  echo "invalid parameter!"
  exit 1
fi 

newOriginData="$1"
tmp=`./uuid.sh`.tmp
awk '{print $2}' "$newOriginData" > "$tmp"
newData=`./uuid.sh`.new
sort "$tmp" > "$newData"

out=`./uuid.sh`.sql
exec 3>"$out"

mysqlConf=(`cat mysql.conf`)
if (( ${#mysqlConf[*]} != 4 )); then
  echo "invalid mysql config!"
  exit 1
fi
mysql -h${mysqlConf[0]} -u${mysqlConf[1]} -P${mysqlConf[2]}  -p${mysqlConf[3]} \
  -e "use sz_house_list; select hetongliushuihao from second_hand;" > "$tmp"
if (( $? != 0 )); then
  echo "access mysql failed!"
  exit 1
fi
sed -i '1d' "$tmp"
oldData=`./uuid.sh`.old
sort "$tmp" > "$oldData"

diffData=`./uuid.sh`.diff
diff "$oldData" "$newData" > "$diffData"
exec 4<"$diffData"
sold="已售"
onsell="在售"
date=`date +%F`
counter=0
pattern='^[0-9]+.?[0-9]+'
while ((1)); do
  read -u 4
  if (( $? != 0 )); then
    break
  fi
  line=($REPLY)
  case ${line[0]} in
  "<")
    sql="update second_hand set zhuangtai=\"$sold\", shouchuriqi=\"$date\" where hetongliushuihao=\"${line[1]}\";"
    echo "$sql" >& 3 
    ;;
  ">")
    entry=(`awk '{ if($2=="'"${line[1]}"'"){print $0} }' $newOriginData`)
    if (( ${#entry[*]} < 9 )); then
      echo "parse diff failed in line: ${line[*]}"
      exit 1
    fi
    xiangmumingchen=${entry[0]}
    hetongliushuihao=${entry[1]}
    qushu=${entry[2]}
    mianjipingfangmi=${entry[3]}
    yongtu=${entry[4]}
    if (( ${#entry[*]} >= 10 )); then
      louceng=${entry[5]}
      fangyuanbianma=${entry[6]}
      dailizhongjie=${entry[7]}
      faburiqi=${entry[8]}
      lianxidianhua=${entry[9]}
    else
      louceng="\\N"
      fangyuanbianma=${entry[5]}
      dailizhongjie=${entry[6]}
      faburiqi=${entry[7]}
      lianxidianhua=${entry[8]}
    fi
    jiagewan="\\N"
    weizhi="\\N"
    counter=0
    while (( counter < 3 )); do
      price=(`./sz_second-hand_house_price.sh $fangyuanbianma`)
      if (( ${#price[*]} < 2 || ${price[0]} != 0 )); then
        ((counter++))
        continue
      fi
      isMatch=`echo "${price[1]}" | grep -E "$pattern"`
      if [ -n "$isMatch" ]; then
        jiagewan=${price[1]}
      fi
      break
    done
    counter=0
    while (( counter < 3 )); do
      location=(`./query_location.sh "$xiangmumingchen"`) 
      if (( ${#location[*]} < 2 || ${location[0]} != 0 )); then
        ((counter++))
        continue
      fi
      isMatch=`echo "${location[1]}" | grep -E "$pattern"`
      if [ -n "$isMatch" ]; then
        weizhi="\"${location[1]}\""
      fi
      break
    done
    zhuangtai="$onsell"
    shouchuriqi="\\N"
    sql="insert into second_hand \
        (xiangmumingchen, hetongliushuihao, qushu, mianjipingfangmi, yongtu, \
        louceng, fangyuanbianma, dailizhongjie, faburiqi, lianxidianhua, \
        jiagewan, weizhi, zhuangtai, shouchuriqi) \
        values \
        (\"$xiangmumingchen\", \"$hetongliushuihao\", \"$qushu\", $mianjipingfangmi, \"$yongtu\", \
        $louceng, \"$fangyuanbianma\", \"$dailizhongjie\", \"$faburiqi\", \"$lianxidianhua\", \
        $jiagewan, $weizhi, \"$zhuangtai\", $shouchuriqi);"
    echo "$sql" >& 3 
    ;;
  esac
done

exec 3>&-
mysql -h${mysqlConf[0]} -u${mysqlConf[1]} -P${mysqlConf[2]}  -p${mysqlConf[3]} \
  < "$out"
if (( $? != 0 )); then
  echo "access mysql failed!"
  exit 1
fi
beforeExit
exit 0