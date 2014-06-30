# encoding: utf-8
require 'spec_helper'

describe 'users with interactive shells' do
  before :context do
    @dr = 'docker run --rm -i -t jumanjiman/wormhole'
  end

  it 'should only include "root" and "user"' do
    # Which interactive shells are allowed in container?
    shells = ssh('cat /etc/shells').split($RS)
    shells.map! { |s| s.chomp }.reject! { |s| s.match %r{/sbin/nologin} }

    # Which users have an interactive shell?
    users = []
    records = ssh('getent passwd').split($RS)
    records.each do |r|
      fields = r.split(':')
      users << fields[0] if shells.include?(fields[6].chomp)
    end

    users.should =~ %w(root user)
  end

  describe 'su' do
    it '"user" cannot su' do
      out = ssh('su 2>&1')
      out.should =~ /^su: Authentication failure$/
    end
  end
end
