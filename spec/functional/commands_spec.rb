# encoding: utf-8
require 'spec_helper'

describe 'useful commands' do
  commands = %w(
    docker
    wget
  )

  commands.each do |cmd|
    it '${cmd} is in user path' do
      output = ssh("which #{cmd}").split($RS).last.chomp
      output.should =~ %r{^.*bin/#{cmd}$}
    end
  end
end
