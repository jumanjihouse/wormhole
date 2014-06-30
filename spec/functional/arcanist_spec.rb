# encoding: utf-8
require 'spec_helper'

describe 'arcanist (phabricator client)' do
  it '`arc` is in user path' do
    output = ssh('which arc').split($RS).last.chomp
    output.should =~ %r{^/usr/local/phabricator/arcanist/bin/arc$}
  end

  it '`arc version` is functional' do
    # Output resembles:
    # arcanist 0971c728fea89ac45a67e06cdb89349ad8040c60 (25 Jun 2014)
    # libphutil aae30d7d2a8e5dd1df2cdfbc51353e4e43610160 (27 Jun 2014)
    line = ssh('arc version')
    line.should =~ /^arcanist \w+/
  end

  it 'uses bash autocompletion' do
    line = ssh("arc vers\t")
    line.should =~ /^arcanist \w+/
  end
end
