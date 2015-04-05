#!/bin/bash
set -e

# Improve strength of diffie-hellman-group-exchange-sha256 (Custom DH with SHA2).
# See https://stribika.github.io/2015/01/04/secure-secure-shell.html
#
# Columns in the moduli file are:
# Time Type Tests Tries Size Generator Modulus
#
# This file is provided by the openssh package on Fedora.
moduli=/etc/ssh/moduli
if [[ -f ${moduli} ]]; then
  cp ${moduli} ${moduli}.orig
  awk '$5 >= 2000' ${moduli}.orig > ${moduli}
fi

# Remove weak DSA host keypair, if present.
dsa_key=/media/state/etc/ssh/ssh_host_dsa_key
[[ -f ${dsa_key} ]] && rm -f ${dsa_key}
[[ -f ${dsa_key}.pub ]] && rm -f ${dsa_key}.pub

# Create host keys if necessary.
# These exist in user data volume, so they persist across rebuilds.
for key_type in ed25519 rsa; do
  key_file=/media/state/etc/ssh/ssh_host_${key_type}_key
  [[ -r ${key_file} ]] || ssh-keygen -q -f ${key_file} -N '' -t ${key_type}
done

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
