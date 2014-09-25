# encoding: utf-8
require 'spec_helper'

describe 'shell-shock' do
  # http://web.nvd.nist.gov/view/vuln/detail?vulnId=CVE-2014-6271
  it 'should resolve CVE-2014-6271' do
    cmd = %!env X='() { :;} ; echo busted' /bin/sh -c "echo completed" 2>&1!
    output = ssh(cmd)
    output.should_not =~ /busted/
  end

  # http://web.nvd.nist.gov/view/vuln/detail?vulnId=CVE-2014-7169
  it 'should resolve CVE-2014-7169' do
    cmd = %!env X='() { (a)=>\' sh -c "echo date" 2> /dev/null; cat echo 2>&1!
    output = ssh(cmd)
    output.should =~ /No such file or directory/
  end
end
