#!/bin/bash

user=$1
if test -z $user; then
  echo "Usage: $(basename $0) <username> <port>" 2> /dev/null
  exit 1
fi

port=$(docker port $user-run 22 | cut -d: -f2)
base_image=jumanjiman/devenv

# stop and throw away user runtime container
docker stop $user-run
docker rm $user-run

# create a runtime container from the base image
docker run -d -t -m 512m --volumes-from $user-data -p $port:22 -h wormhole.example.com --name $user-run $base_image
