# encoding: utf-8
require 'spec_helper'

describe 'eiffelstudio' do
  it 'has command-line eiffel compiler in path' do
    dr = 'docker run --rm -i -t jumanjiman/wormhole sh -l -c "which ec"'
    output = `#{dr} 2> /dev/null`.split($RS).last.chomp
    output.should =~ %r{^/usr/local/Eiffel.*/bin/ec$}
  end

  it 'has estudio in path' do
    dr = 'docker run --rm -i -t jumanjiman/wormhole sh -l -c "which estudio"'
    output = `#{dr} 2> /dev/null`.split($RS).last.chomp
    output.should =~ %r{^/usr/local/Eiffel.*/bin/estudio$}
  end
end
