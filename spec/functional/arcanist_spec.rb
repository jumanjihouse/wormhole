# encoding: utf-8
require 'spec_helper'

describe 'arcanist (phabricator client)' do
  it '`arc` is in user path' do
    dr = 'docker run --rm -i -t jumanjiman/wormhole sh -l -c "which arc"'
    output = `#{dr} 2> /dev/null`.split($RS).last.chomp
    output.should =~ %r{^/usr/local/phabricator/arcanist/bin/arc$}
  end

  it '`arc version` is functional' do
    dr = 'docker run --rm -i -t jumanjiman/wormhole sh -l -c "arc version"'
    system("#{dr} 2> /dev/null").should be_truthy
  end
end
