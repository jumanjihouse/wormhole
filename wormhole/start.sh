#!/bin/bash
set -e

if [[ ${DUO} == true ]]; then
  pushd /etc/pam.d/ &> /dev/null
  patch -p0 < password-auth.patch
  popd &> /dev/null

  # /etc/duo/login_duo.conf must be readable only by user 'user'
  cp /etc/duo/login_duo.conf /etc/duo/${instance}.conf
  chown user:user /etc/duo/${instance}.conf
  chmod 0400 /etc/duo/${instance}.conf

  /usr/sbin/sshd -D -e -o ForceCommand="/usr/sbin/login_duo -c /etc/duo/${instance}.conf -f ${instance}"
else
  /usr/sbin/sshd -D -e
fi
