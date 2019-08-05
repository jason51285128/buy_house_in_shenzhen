#!/bin/bash

if (( $# != 2 )); then
exit 1
fi

action=$1
followers=$2

fd=3
declare -a outfd
declare -a infd
declare -a isOver
overCounter=0

for (( k = 0; k < ${#followers[*]}; k++ )); do
  rm -f ${#followers[$k]}.out
done 

i=0
for parameters in `./house_graber_split.sh $followers`; do
  msginFile=/tmp/`./uuid.sh`
  msgoutFile=/tmp/`./uuid.sh`
  mkfifo $msginFile
  mkfifo $msgoutFile

  {
    exec 3<$msgoutFile
    exec 4>$msginFile
    hostPort=`echo $parameters | cut -d " " -f1`
    host=`echo $hostPort | cut -d ":" -f1`
    port=host=`echo $hostPort | cut -d ":" -f2`
    ncat $host $port <&3 >&4 2>/dev/null 
  } &

  exec $fd<$msginFile
  infd[$i]=$fd
  ((fd++))
  exec $fd>$msgoutFile
  outfd[$i]=$fd
  ((fd++))

  
  startPage=`echo $parameters | cut -d " " -f2`
  endPage=`echo $parameters | cut -d " " -f3`
  echo $action $startPage $endPage >& ${outfd[$i]}

  ((i++))
  rm -f $msginFile $msgoutFile
done

while ((1)); do
for (( j = 0; j < ${#infd[*]}; j++ )); do
  read -u ${#infd[$j]} -t 60
  if (( $? != 0 )); then
    break
  fi
  if [ "$REPLY" == "EOF" ]; then
    
  else
  fi 
done
if (( $? != 0 )); then
  break
fi
done