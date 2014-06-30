# encoding: utf-8
require 'spec_helper'

# https://github.com/jumanjiman/bz1099206
describe 'BZ1099206 (slow test)' do
  it 'home directory should exist' do
    output = ssh('ls -d /home/user')
    output.should =~ %r{^/home/user$}
  end

  it 'go get should work' do
    go_cmd = [
      'export GOPATH=/home/user/gocode',
      '/usr/bin/go get github.com/epeli/hooktftp',
      'ls /home/user/gocode/bin/hooktftp',
    ].join(';')
    output = ssh(go_cmd)
    output.should =~ %r{^/home/user/gocode/bin/hooktftp$}
  end
end
