#!/bin/bash

# Import smitty.
source script/functions

user=$1

test -z $user && err "Usage: $(basename $0) <username>"
test -f $user-data.tar && err $user-data.tar already exists
smitty sudo systemctl stop wormhole@$user
smitty sudo systemctl disable wormhole@$user
smitty ./backup.sh $user
smitty docker rm $user-data
smitty docker rm $user
smitty sudo rm -f /etc/wormhole/${user}.conf
