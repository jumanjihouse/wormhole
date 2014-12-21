# encoding: utf-8
require 'spec_helper'

describe 'locale archive' do
  locales = [
    'C',
    'POSIX',
    'en_US.utf8',
    'en_US.UTF-8',
  ]

  locales.each do |locale|
    it "supports #{locale}" do
      output = ssh("export LANG=#{locale}; locale -a 2>&1")
      output.should_not =~ /Cannot/
    end
  end
end
