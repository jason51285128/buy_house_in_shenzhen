#!/bin/bash

PWD=$(cd "$(dirname "$0")";pwd)
conf="leader_election.json"
electionTimeout=3
leardHeartBeatTimeout=3
broker=

follower="follower"
leader="leader"
candidate="candidate"
term=1
state=$follower

help()
{
    cat <<  HERE
    usage: ./leader_election.sh -f config_file.json
      -f: specify configuration file, default "leader_election.json"
HERE
}

parseConfig()
{
  electionTimeout=`cat "$conf" | jq .electionTimeout | cut -d "\"" -f2`
  leardHeartBeatTimeout=`cat "$conf" | jq .leardHeartBeatTimeout| cut -d "\"" -f2`
  broker=`cat "$conf" | jq .broker | cut -d "\"" -f2`
}

while getopts "f:h" arg
do
    case $arg in
    f)
    conf=$OPTARG
    parseConfig
    ;;
    h)
    help
    exit 0
    ;;
    ?)
    help
    exit 1
    ;;
    esac
done