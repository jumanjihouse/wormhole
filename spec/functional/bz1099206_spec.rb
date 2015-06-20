# encoding: utf-8
require 'spec_helper'

# https://github.com/jumanjiman/bz1099206
#
# We need golang-1.2.2-22.fc20 or later:
# https://admin.fedoraproject.org/updates/FEDORA-2014-9424/golang-1.2.2-22.fc20
describe 'BZ1099206 (slow test)' do
  before :context do
    @state = @app.json['State']
    pp @state if debug?
  end

  it 'should be running' do
    @state['Running'].should be_truthy
  end

  it 'home directory should exist' do
    pending 'debug'
    output = ssh('tree -a /home/user')
    output.should =~ %r{^/home/user$}
  end

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
