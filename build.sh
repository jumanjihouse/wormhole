#!/bin/bash
set -e
set -o noclobber

# Import smitty.
source script/functions

user=$1
pubkey=$2
if test -z $user ; then
  echo "Usage: $(basename $0) <username> <pubkey>" 2> /dev/null
  exit 1
fi

global_config=/etc/wormhole/global.conf

sudo mkdir -p /etc/wormhole || :
[[ -r $global_config ]] || sudo cp -f global.conf /etc/wormhole/
source $global_config

duo_config=/etc/wormhole/login_duo.conf
[[ -r $duo_config ]] || sudo cp -f login_duo.conf /etc/wormhole/

rm -f data
cat >> data <<EOF
FROM   busybox
RUN    mkdir -p /home/user
VOLUME ["/home/user", "/media/state/etc/ssh"]
CMD    ["/bin/true"]
EOF

# build new data image and remove intermediate containers
docker rmi data 2> /dev/null || :
cat data | docker build --rm -t data -

# create tiny data container named $user-data
smitty docker rm $user-data 2> /dev/null || :
smitty docker run -v /home/user -v /media/state/etc/ssh --name $user-data busybox true

# remove the data image since we no longer need it
smitty docker rmi data || :

# add contents of /etc/skel into data container
smitty docker run --rm --volumes-from $user-data -u root $base_image cp /etc/skel/.bash* /home/user

# fix ownership of homedir
smitty docker run --rm --volumes-from $user-data -u root $base_image chown -R user:user /home/user

# add ssh keys
smitty docker run --rm --volumes-from $user-data -u user $base_image mkdir -p /home/user/.ssh
smitty docker run --rm --volumes-from $user-data -u user $base_image chmod 0700 /home/user/.ssh
smitty docker run --rm --volumes-from $user-data -u user $base_image /bin/bash -c "echo $pubkey >> /home/user/.ssh/authorized_keys"
smitty docker run --rm --volumes-from $user-data -u user $base_image chmod 0600 /home/user/.ssh/authorized_keys
smitty curl --silent -m 10 -O https://api.github.com/users/${user}/keys
if [[ $? -eq 0 ]]; then
  [[ -x ./jq ]] || curl -O http://stedolan.github.io/jq/download/linux64/jq
  chmod 0755 ./jq
  old_ifs=$IFS
  IFS=$'\n'
  for pubkey in $(./jq -r '.[].key' keys ); do
    smitty docker run --rm --volumes-from $user-data -u user $base_image /bin/bash -c "echo $pubkey >> /home/user/.ssh/authorized_keys"
  done
  IFS=$old_ifs
  rm -f keys
fi

# create a container from the user image
smitty docker run -d -t -m $max_ram --volumes-from $user-data -P -h $sandbox_hostname --name $user $base_image
port=$(docker port $user 22 | cut -d: -f2)
smitty docker stop $user
smitty docker rm $user

# Make the container persistent.
smitty sudo cp -f wormhole@.service /etc/systemd/system/
echo -e "PORT=$port\n" | sudo tee /etc/wormhole/${user}.conf
smitty sudo systemctl enable wormhole@$user
smitty sudo systemctl start wormhole@$user
smitty sleep 2
smitty sudo systemctl status wormhole@$user
