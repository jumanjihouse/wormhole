#!/bin/bash
set -e

version='20091111'

pushd /tmp/
for app in jing trang; do
  curl -s -O https://jing-trang.googlecode.com/files/${app}-${version}.zip
  unzip -q ${app}-${version}.zip
  mkdir /opt/$app || :
  find ${app}-${version} -regex '.*\.jar' -exec cp -f {} /opt/$app/ \;
done
