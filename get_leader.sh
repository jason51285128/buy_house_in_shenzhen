#!/bin/bash

if (( $# != 2 )); then
exit 1
fi

broker="$1"
hearbeatThreshold="$2"


msgoutFile=`./uuid.sh`
msginFile=`uuid.sh`
mkfifo /tmp/$msgoutFile
mkfifo /tmp/$msginFile

{
  exec 3<$msgoutFile
  exec 4>$msginFile
  nc $broker <&3 >&4 2>/dev/null &
}

msgout=3
msgin=4
exec 3>$msgoutFile
exec 4<$msginFile

{
  leader="("
  MSG_TYPE_I_AM_LEADER=5

  while (( 1 )) ; do 
    read -u $msgin msgType senderAddr senderId sendts msgBody
    if (( $? != 0 )); then
      leader="$leader)"
      echo "$broker $hearbeatThreshold $leader"
      exit 0
    fi
    if (( msgType == MSG_TYPE_I_AM_LEADER )); then
      isNewer=`echo "$leader" | grep $senderAddr`
      if [ -z "$isNewer" ]; then
      leader="$leader$senderAddr "
      fi
    fi
  done
}

MSG_TYPE_WHO_IS_LEADER=4
ts=`./send_ts.sh`

echo "$MSG_TYPE_WHO_IS_LEADER NULL NULL $ts" >& $msgout

waitInterval=$(( hearbeatThreshold * 2 ))
sleep $waitInterval
exec $msgout>&-
sleep 3