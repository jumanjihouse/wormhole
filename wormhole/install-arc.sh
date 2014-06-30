#!/bin/bash
set -e

phab_dir=/usr/local/phabricator
arc_dir=${phab_dir}/arcanist

cat >> /etc/profile.d/arc.sh <<EOF
# Depends on php!
pathmunge ${arc_dir}/bin after
source ${arc_dir}/resources/shell/bash-completion
EOF

mkdir -p ${phab_dir}
pushd ${phab_dir}
git clone https://github.com/phacility/libphutil.git
git clone https://github.com/phacility/arcanist.git
