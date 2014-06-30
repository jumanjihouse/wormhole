# encoding: utf-8
require 'spec_helper'

describe 'user convenience' do
  it 'man -k returns results' do
    output = ssh('man -k git').split($RS)
    output.length.should >= 10
  end

  # @note This rspec also asserts that /etc/issue.net is available for sshd.
  it 'locate returns the path for issue.net' do
    output = ssh('locate issue.net')
    output.should =~ %r{^/etc/issue.net$}
  end
end
