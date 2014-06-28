# encoding: utf-8
require 'spec_helper'

# https://github.com/jumanjiman/bz1099206
describe 'BZ1099206' do
  it 'go get should work' do
    dr = 'docker run --rm -i -t -u user jumanjiman/wormhole bash -c'
    go_cmd = [
      'export GOPATH=/home/user/gocode',
      'mkdir -p /home/user/bin',
      'go get github.com/epeli/hooktftp',
    ].join(';')
    system("#{dr} \"#{go_cmd}\"").should be_truthy
  end
end
