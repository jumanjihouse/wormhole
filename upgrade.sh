#!/bin/bash

user=$1
if test -z $user; then
  echo "Usage: $(basename $0) <username> <port>" 2> /dev/null
  exit 1
fi

source ./global.conf

port=$(docker port $user 22 | cut -d: -f2)

# stop and throw away user runtime container
docker stop $user
docker rm $user

# create a runtime container from the base image
docker run -d -t -m $max_ram --volumes-from $user-data -p $port:22 -h $sandbox_hostname --name $user $base_image
