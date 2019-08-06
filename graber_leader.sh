#!/bin/bash

if (( $# != 2 )); then
exit 1
fi

action=$1
followers=($2)
declare -a outfd
declare -a infd
declare -a startPage
declare -a endPage
fd=3

#function define
beforeExit() {
  closeAllInPipe
  emptyAllSubOutFile
} 

closeAllInPipe()
{
  for (( i = 0; k < ${#infd[*]}; i++ )); do
    exec  ${infd[$i]} >& -
  done
}

emptyAllSubOutFile()
{
  for (( i = 0; k < ${#followers[*]}; i++ )); do
    rm -f ${followers[$i]}.out
  done
}

#parse parameter
i=0
for parameters in `./house_graber_split.sh "\"${followers[*]}\"" `; do
  startPage[$i]=`echo $parameters | cut -d " " -f2`
  endPage[$i]=`echo $parameters | cut -d " " -f3`
  ((i++))
done

#set up connect and pipe
for (( i=0; i < ${#followers[*]}; i++ )); do
  msginFile=/tmp/`./uuid.sh`
  msgoutFile=/tmp/`./uuid.sh`
  mkfifo $msginFile
  mkfifo $msgoutFile

  {
    exec 3<$msgoutFile
    exec 4>$msginFile
    host=`echo ${followers[$i]} | cut -d ":" -f1`
    port=host=`echo ${followers[$i]} | cut -d ":" -f2`
    ncat $host $port <&3 >&4 2>/dev/null 
  } &

  exec $fd>$msgoutFile
  outfd[$i]=$fd
  ((fd++))
  exec $fd<$msginFile
  infd[$i]=$fd
  ((fd++))

  rm -f $msginFile $msgoutFile
done

#check array length
if (( !(${#followers[*]} == ${#infd[*]}  && ${#infd[*]} == ${#outfd[*]} && ${#outfd[*]} == ${#startPage[*]} &&  ${#startPage[*]} == ${#endPage[*]}) )); then
  echo "internal error!"
  beforeExit
  exit 1 
fi

#read from pipe until finish or fail
declare -a isover
while ((1)); do
  overCounter=0
  isFialed=0
  for (( i = 0; i < ${#infd[*]}; i++ )); do
    isover[$i]=0
  done
  emptyAllSubOutFile

  #start grab
  echo "start grab task..."
  for (( i=0; i < ${#followers[*]}; i++ )); do
    echo ${followers[$i]} ${startPage[$i]} ${endPage[$i]}
    echo $action ${startPage[$i]} ${endPage[$i]} >& ${outfd[$i]}
  done

  while (( isFialed==0 &&  overCounter < ${#infd[*]} )); do
    for (( i = 0; i < ${#infd[*]}; i++ )); do
      if (( ${isover[$i]} == 1 )); then
        continue
      fi
      read -u ${infd[$i]} -t 60
      if (( $? != 0 )); then
        isFialed=1
        break
      fi
      if [ "$REPLY" == "EOF" ]; then
        ((overCounter++))
        isover[$i]=1
      else
        echo "$REPLY" >> ${followers[i]}.out
      fi 
    done
  done

  if (( isFialed != 0 )); then
    ./post_dingding_msg.sh "error when read pip! graber leader exit..."
    beforeExit
    exit 1    
  fi

  out=graber_leader-`./send_ts.sh`
  for (( i=0; i < ${#followers[*]}; i++ )); do
    cat ${followers[$i]}.out >> $out
    cat /dev/null > ${followers[$i]}.out
  done
  ./post_dingding_msg.sh "graber task success!"

  sleep 1800
done