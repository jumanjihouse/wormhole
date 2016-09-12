#!/bin/bash
set -e

echo jing-trang has moved to https://github.com/relaxng/jing-trang
echo and must be built from scratch.
exit 0

version='20091111'

pushd /tmp/
for app in jing trang; do
  curl -s -O https://jing-trang.googlecode.com/files/${app}-${version}.zip
  unzip -q ${app}-${version}.zip
  mkdir -p /opt/$app || :
  find ${app}-${version} -regex '.*\.jar' -exec cp -f {} /opt/$app/ \;
done
