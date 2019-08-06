#!/bin/bash

if (( $# != 2 )); then
exit 1
fi

host="$1"
port="$2"

ncat -e /bin/bash -l -k $host $port
