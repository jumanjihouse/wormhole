#!/bin/bash
set -e

dirs="
/lib64
/usr/lib
/usr/lib64
/usr/bin
/usr/local/bin
/sbin
/usr/sbin
/usr/local/sbin
"
for dir in $dirs; do
  # If any file has group or world write privilege, remove that privilege.
  find $dir -type f -perm /go=w -exec chmod go-w {} +
done

# Disable direct root login on any terminal.
> /etc/securetty

# Enable "user" to read this file since we run oscap as "user".
# If "user" cannot read the file, the oscap check errors out.
chmod 0444 /etc/securetty

# Disable empty password support from PAM.
sed -r -i 's/\<nullok\>//g' /etc/pam.d/*

# We disable password auth, but adjust these settings anyway
# to avoid tailoring the SCAP benchmark.
sed -i 's/^PASS_MAX_DAYS.*$/PASS_MAX_DAYS   60/' /etc/login.defs
sed -i 's/^PASS_MIN_DAYS.*$/PASS_MIN_DAYS   7/'  /etc/login.defs
sed -i 's/^PASS_MIN_LEN.*$/PASS_MIN_LEN    12/'  /etc/login.defs
