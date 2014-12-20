# encoding: utf-8
require 'spec_helper'

describe 'ldc D compiler' do
  before :context do
    ssh('git clone https://github.com/CyberShadow/dhcptest.git')
  end

  # This test ensures several things are functional:
  # - gcc compiler
  # - ldc2 compiler
  # - git
  it 'compiles a D program' do
    pending 'https://bugzilla.redhat.com/show_bug.cgi?id=1176361'

    # rubocop:disable LineLength
    cmd = 'cd dhcptest; ldc2 dhcptest.d; chmod 0755 dhcptest; ./dhcptest -h 2>&1'
    # rubocop:enable LineLength
    ssh(cmd).should match(/^Usage: \.\/dhcptest/)
  end
end
