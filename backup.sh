#!/bin/bash

user=$1
if test -z $user; then
  echo "Usage: $(basename $0) <username>" 2> /dev/null
  exit 1
fi

docker run -rm --volumes-from $user-data -v $(pwd):/backup busybox tar cvf /backup/$user-data.tar /home/$user
