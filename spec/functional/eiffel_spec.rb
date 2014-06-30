# encoding: utf-8
require 'spec_helper'

describe 'eiffelstudio' do
  it 'has command-line eiffel compiler in path' do
    output = ssh('which ec')
    output.should =~ %r{^/usr/local/Eiffel.*/bin/ec$}
  end

  it 'has estudio in path' do
    output = ssh('which estudio')
    output.should =~ %r{^/usr/local/Eiffel.*/bin/estudio$}
  end
end
