#!/bin/bash

if (( $# != 3 )); then
exit 1
fi

broker="$1"
hearbeatThreshold="$2"
leaderAddr="$3"
if (( ${#leaderAddr[*]} > 1 )); then
exit 1
fi



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
  followers="("
  MSG_TYPE_I_AM_FOLLOWER=3

  while (( 1 )) ; do 
    read -u $msgin msgType senderAddr senderId sendts msgBody
    if (( $? != 0 )); then
      followers="$followers)"
      echo $followers
      exit 0
    fi
    if (( msgType == MSG_TYPE_I_AM_FOLLOWER )); then
      isNewer=`echo "$followers" | grep $senderAddr`
      if [ -z "$isNewer" ]; then
      followers="$followers$senderAddr "
      fi
    fi
  done
}

MSG_TYPE_WHO_IS_FOLLOWER=2
ts=`./send_ts.sh`

echo "$MSG_TYPE_WHO_IS_FOLLOWER NULL NULL $ts ${leaderAddr[0]}" >& $msgout

waitInterval=$(( hearbeatThreshold * 2 ))
sleep $waitInterval
exec $msgout>&-
sleep 3