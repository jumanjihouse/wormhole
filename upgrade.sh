#!/bin/bash

user=$1
port=$2
if test -z $user -o -z $port; then
  echo "Usage: $(basename $0) <username> <port>" 2> /dev/null
  exit 1
fi

# stop and throw away user runtime container
docker stop $user-run
docker rm $user-run

# create a runtime container from the base image
docker run -d -t --volumes-from $user-data -p $port:22 -h wormhole.example.com --name $user-run jumanjiman/booga
