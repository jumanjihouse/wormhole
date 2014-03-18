#!/bin/bash

user=$1
pubkey=$2
if test -z $user -o -z $pubkey; then
  echo "Usage: $(basename $0) <username> <pubkey>" 2> /dev/null
  exit 1
fi

cat > data <<EOF
FROM   busybox
RUN    mkdir -p /home/$user
VOLUME ["/home/$user"]
CMD    ["/bin/true"]
EOF


cat > user <<EOF
FROM    booga:latest
RUN     useradd $user
#USER   $user
VOLUME  ["/home/$user"]
WORKDIR /home/$user
ENV     HOME /home/$user
EOF

# build new data image and remove intermediate containers
docker rmi data 2> /dev/null
cat data | docker build -rm -t data -

# create tiny data container named $user-data
docker rm $user-data 2> /dev/null
docker run -v /home/$user -name $user-data busybox true

# remove the data image since we no longer need it
docker rmi data

# build user image named $user
docker rmi $user 2> /dev/null
cat user | docker build -rm -t $user -

# add contents of /etc/skel into data container
# via a throwaway container based on user image
docker run -rm -volumes-from $user-data -u root $user cp /etc/skel/.bash* /home/$user

# fix ownership of homedir
docker run -rm -volumes-from $user-data -u root $user chown -R $user:$user /home/$user

# add ssh keys
docker run -rm -volumes-from $user-data -u $user $user mkdir -p /home/$user/.ssh
docker run -rm -volumes-from $user-data -u $user $user chmod 0700 /home/$user/.ssh
docker run -rm -volumes-from $user-data -u $user $user /bin/bash -c "echo $pubkey > /home/$user/.ssh/authorized_keys"
docker run -rm -volumes-from $user-data -u $user $user chmod 0600 /home/$user/.ssh/authorized_keys

# create a container from the user image
docker run -d -volumes-from $user-data -P -h dev.example.com -name $user-run $user
