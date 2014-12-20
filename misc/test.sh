#!/bin/bash

# See https://bugzilla.redhat.com/show_bug.cgi?id=1176361

# $ ./test.sh
# docker pull fedora:20
# fedora:20: The image you are pulling has been verified
# 511136ea3c5a: Already exists
# 782cf93a8f16: Already exists
# 2e613b1df961: Already exists
# Status: Image is up to date for fedora:20
#
# docker pull fedora:latest
# fedora:latest: The image you are pulling has been verified
# 511136ea3c5a: Already exists
# 00a0c78eeb6d: Already exists
# bfe0bb6667e4: Already exists
# Status: Image is up to date for fedora:latest
#
# docker pull ubuntu:latest
# ubuntu:latest: The image you are pulling has been verified
# 511136ea3c5a: Already exists
# c7b7c6419568: Already exists
# 70c8faa62a44: Already exists
# d735006ad9c1: Already exists
# 04c5d3b7b065: Already exists
# Status: Image is up to date for ubuntu:latest
#
# =========================
# Running in Fedora 20 (Heisenbug)
# -------------------------
# install packages
# -snip lots of output-
#
# =========================
# Running in Fedora 21 (Twenty One)
# -------------------------
# install packages
# -snip lots of output-
#
# =========================
# Running in Ubuntu 14.04.1 LTS, Trusty Tahr
# -------------------------
# install packages
# -snip lots of output-
#
# =======
# SUMMARY for Sat Dec 20 21:23:39 UTC 2014
# -------
# Fedora 20 (Heisenbug) branch master FAILS to compile
# Fedora 20 (Heisenbug) branch heads/0.4 compiles OK and runs OK
# Fedora 21 (Twenty One) branch master compiles OK but FAILS to run
# Fedora 21 (Twenty One) branch heads/0.4 compiles OK but FAILS to run
# Ubuntu 14.04.1 LTS, Trusty Tahr branch master compiles OK and runs OK
# Ubuntu 14.04.1 LTS, Trusty Tahr branch heads/0.4 compiles OK and runs OK

images='
fedora:20
fedora:latest
ubuntu:latest
'

clone_repo() {
  cd
  git clone https://github.com/CyberShadow/dhcptest.git
  cd dhcptest
}

{
echo ===================
echo SUMMARY for $(date)
echo -------------------
} >> summary

run_dhcptest() {
  echo
  echo run dhcptest
  branch_name=$(git rev-parse --abbrev-ref HEAD)
  echo -n "$NAME $VERSION branch $branch_name " >> /tmp/summary
  if [[ -x dhcptest ]]; then
    echo -n compiles OK >> /tmp/summary
    ./dhcptest -h 2>&1 | tee output
    {
      if grep -q 'Usage: ./dhcptest' output; then
        echo ' and runs OK'
      else
        echo ' but FAILS to run'
      fi
    } | tee -a /tmp/summary
  else
    echo FAILED to compile >> /tmp/summary
  fi
}

compile_with_gdc() {
  echo
  echo compile with gdc
  gdc -o dhcptest dhcptest.d
  run_dhcptest
}

compile_with_ldc() {
  echo
  echo compile with ldc2
  ldc2 dhcptest.d
  echo
  run_dhcptest
}

if [[ -n $INSIDE_DOCKER ]]; then
  . /etc/os-release
  echo
  echo
  echo =========================
  echo Running in $NAME $VERSION
  echo -------------------------

  if [[ $NAME =~ Fedora ]]; then
    echo install packages
    yum -y install git ldc gcc

    clone_repo
    compile_with_ldc

    git checkout -b 0.4 0.4
    compile_with_ldc
  fi

  if [[ $NAME =~ Ubuntu ]]; then
    echo install packages
    apt-get update
    apt-get install -q -y git gdc gcc

    clone_repo
    compile_with_gdc

    git checkout -b 0.4 0.4
    compile_with_gdc
  fi

  exit
else
  # Download the docker images.
  for img in $images; do
    echo docker pull $img
    docker pull $img
    echo
  done

  # Attempt to compile D program.
  for img in $images; do
    docker run --rm -i -e INSIDE_DOCKER=yes -v $(pwd):/tmp $img /tmp/test.sh
  done

  echo
  cat summary
fi
