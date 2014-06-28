# encoding: utf-8
require 'spec_helper'

describe 'user convenience' do
  it 'man -k returns results' do
    dr = 'docker run --rm -i -t jumanjiman/wormhole man -k git 2> /dev/null'
    output = `#{dr} 2> /dev/null`.split($RS)
    output.length.should >= 10
  end

  # @note This rspec also asserts that /etc/issue.net is available for sshd.
  it 'locate returns the path for issue.net' do
    dr = 'docker run --rm -i -t jumanjiman/wormhole locate issue.net'
    output = `#{dr} 2> /dev/null`.split($RS)
    output[0].chomp.should =~ %r{/etc/issue.net}
  end
end
