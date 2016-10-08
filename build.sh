#!/bin/bash

user=$1
handle=$2
base_image="jumanjiman/wormhole:wip"

# add contents of /etc/skel into data container
docker create -v /home/user -v /media/state/etc/ssh --name $user-data busybox true

# add contents of /etc/skel into data container
docker run --rm --volumes-from $user-data -u root --entrypoint=bash $base_image -c "cp /etc/skel/.bash* /home/user"

# fix ownership of home dir
docker run --rm --volumes-from $user-data -u root --entrypoint=bash $base_image -c "mkdir /home/user/.ssh"
docker run --rm --volumes-from $user-data -u root --entrypoint=bash $base_image -c "chown -R user:user /home/user"

# add ssh keys
curl --silent -m 10 -O https://api.github.com/users/${handle}/keys
if [[ $? -eq 0 ]]; then
  old_ifs=$IFS
  IFS=$'\n'
  for pubkey in $(jq -r '.[].key' keys ); do
    docker run --rm --volumes-from $user-data -u user --entrypoint=bash $base_image -c "echo $pubkey >> /home/user/.ssh/authorized_keys"
  done
  IFS=$old_ifs
  rm -f keys
fi
