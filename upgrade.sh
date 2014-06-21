#!/bin/bash
set -e

# Import smitty.
source script/functions

user=$1
if test -z $user; then
  echo "Usage: $(basename $0) <username>" >&2
  exit 1
fi

smitty docker pull jumanjiman/wormhole
smitty sudo systemctl restart wormhole@$user
smitty sleep 2
smitty sudo systemctl status wormhole@$user
