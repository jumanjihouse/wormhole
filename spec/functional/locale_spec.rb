# encoding: utf-8
require 'spec_helper'

describe 'locale archive' do
  locales = [
    'C',
    'POSIX',
    'en_US.utf8',
  ]

  before :all do
    @all_locales = ssh('locale -a')
  end

  locales.each do |locale|
    it "supports #{locale}" do
      output = ssh("export LANG=#{locale}; locale -a 2>&1")
      output.should_not =~ /Cannot/
      @all_locales.should =~ /^#{locale}$/
    end
  end
end
