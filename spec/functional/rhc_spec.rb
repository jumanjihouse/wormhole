# encoding: utf-8
require 'spec_helper'

describe 'rhc (openshift client)' do
  it '`rhc` is in user path' do
    output = ssh('which rhc').split($RS).last.chomp
    output.should =~ %r{.*/bin/rhc$}
  end

  it '`rhc --version` is functional' do
    # Output resembles:
    # rhc 1.27.4
    output = ssh('rhc --version')
    output.should =~ /^rhc .+/
  end
end
