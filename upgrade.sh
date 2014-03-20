#!/bin/bash

user=$1
port=$2
if test -z $user -o -z $port; then
  echo "Usage: $(basename $0) <username> <port>" 2> /dev/null
  exit 1
fi

cat > user <<EOF
FROM    booga:latest
RUN     useradd $user
VOLUME  ["/home/$user"]
EOF

# stop and throw away user runtime container
docker stop $user-run
docker rm $user-run

# build user image named $user
docker rmi $user 2> /dev/null
cat user | docker build --rm -t $user -

# create a runtime container from the user image
docker run -d --volumes-from $user-data -p $port:22 -h dev --name $user-run $user
