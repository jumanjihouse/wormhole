# encoding: utf-8
require 'spec_helper'

describe 'prohibited packages' do
  prohibited_packages = %w(
    at
    sudo
  )

  prohibited_packages.each do |package|
    it "should not have #{package} installed" do
      dr = 'docker run --rm -i -t jumanjiman/wormhole'
      output = `#{dr} rpm -q #{package} 2> /dev/null`.split($RS)
      output[0].chomp.should =~ /^package #{package} is not installed$/
    end
  end
end

# Multiple packages can provide some commands, so
# we check for the commands, too.
# Multiple CCE's recommend restricting at and cron.
describe 'prohibited commands' do
  prohibited_commands = %w(
    at
    crond
    crontab
  )

  prohibited_commands.each do |cmd|
    it "should not have the #{cmd} command" do
      dr = "docker run --rm -i -t jumanjiman/wormhole which #{cmd}"
      output = `#{dr} 2> /dev/null`.split($RS)
      output[0].chomp.should =~ /no #{cmd} in/
    end
  end
end
