#!/bin/bash

user=$1
if test -z $user; then
  echo "Usage: $(basename $0) <username>" 2> /dev/null
  exit 1
fi

docker run -v /home/user -v /media/state/etc/ssh --name $user-data busybox true
docker run --rm --volumes-from $user-data -v $(pwd):/backup busybox tar xvf /backup/$user-data.tar
