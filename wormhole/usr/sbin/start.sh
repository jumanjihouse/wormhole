#!/bin/sh
set -e

# Env vars from systemd:
# - GITHUB_HANDLE
# - ISE_USERNAME
# - IKEY
# - SKEY

# Create host keys if necessary.
# These exist in user data volume, so they persist across rebuilds.
# sshd_config specifies to use these files.
for key_type in ed25519 rsa; do
  key_file=/media/state/etc/ssh/ssh_host_${key_type}_key
  [ -s ${key_file} ] || ssh-keygen -q -f ${key_file} -N '' -t ${key_type}
done

if [ -n "${IKEY}" -a -n "${SKEY}" ]; then
  cp /etc/duo/login_duo.conf /etc/duo/${instance}.conf
  sed -i "s/^ikey.*/ikey = ${IKEY}/g" /etc/duo/${instance}.conf
  sed -i "s/^skey.*/skey = ${SKEY}/g" /etc/duo/${instance}.conf

  # /etc/duo/login_duo.conf must be readable only by user 'user'
  chown user:user /etc/duo/${instance}.conf
  chmod 0400 /etc/duo/${instance}.conf
fi

if [ -n "${GITHUB_HANDLE}" ]; then
  echo "GITHUB_HANDLE=${GITHUB_HANDLE}" > /home/user/.wormholerc
  (
    keyfile=/home/user/.ssh/authorized_keys
    IFS=$'\n'
    for key in $(/usr/bin/github_pubkeys); do
      grep "${key}" ${keyfile} &> /dev/null || echo ${key} >> ${keyfile}
    done
  )
fi

exec /usr/sbin/sshd -D -e -o ForceCommand="/usr/sbin/login_duo -c /etc/duo/${instance}.conf -f ${instance}"
