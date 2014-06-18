#!/bin/bash
set -e

user=$1
if test -z $user; then
  echo "Usage: $(basename $0) <username>" >&2
  exit 1
fi

docker pull jumanjiman/wormhole
sudo systemctl restart wormhole@$user
sleep 2
sudo systemctl status wormhole@$user
