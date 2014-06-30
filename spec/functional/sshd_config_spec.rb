# encoding: utf-8
require 'spec_helper'

describe 'sshd config' do
  before :context do
    @config = ssh('/usr/sbin/sshd -T 2> /dev/null')
  end

  describe 'auth' do
    allow_auth = %w(
      pubkeyauthentication
    )

    deny_auth = %w(
      passwordauthentication
      gssapiauthentication
      kerberosauthentication
      challengeresponseauthentication
    )

    it 'should use privilege separation' do
      @config.should =~ /^useprivilegeseparation yes\r*$/
    end

    it 'should use pam' do
      @config.should =~ /^usepam 1\r*$/
    end

    allow_auth.each do |allow|
      it "should allow #{allow}" do
        @config.should =~ /^#{allow} yes\r*$/
      end
    end

    deny_auth.each do |deny|
      it "should deny #{deny}" do
        @config.should =~ /^#{deny} no\r*$/
      end
    end
  end

  describe 'tunnels and forwarding' do
    it 'should deny ssh tunnels' do
      @config.should =~ /^permittunnel no\r*$/
    end

    it 'should deny TCP forwarding' do
      @config.should =~ /^allowtcpforwarding no\r*$/
    end

    # @note I could be convinced to allow X11 forwarding.
    it 'should deny X11 forwarding' do
      @config.should =~ /^x11forwarding no\r*$/
    end

    it 'should deny gateway ports' do
      @config.should =~ /^gatewayports no\r*$/
    end
  end

  describe 'Common Configuration Enumeration (CCE)' do
    it 'CCE-3660-8 Disable remote ssh from accounts with empty passwords' do
      @config.should =~ /^permitemptypasswords no\r*$/
    end

    it 'CCE-3845-5 idle timeout interval should be set appropriately' do
      @config.should =~ /^clientaliveinterval 900\r*$/
    end

    it 'CCE-4325-7 Disable SSH protocol version 1' do
      @config.should =~ /^protocol 2\r*$/
      @config.should_not =~ /^protocol 1\r*$/
    end

    it 'CCE-4370-3 Disable SSH host-based authentication' do
      @config.should =~ /^hostbasedauthentication no\r*$/
    end

    it 'CCE-4387-7 Disable root login via SSH' do
      @config.should =~ /^permitrootlogin no\r*$/
    end

    it 'CCE-4431-3 SSH warning banner should be enabled' do
      @config.should =~ %r{^banner /etc/issue\.net\r*$}
    end

    it 'CCE-4475-0 Disable emulation of rsh command through sshd' do
      @config.should =~ /^ignorerhosts yes\r*$/
    end

    it 'CCE-14061-6 "keep alive" msg count should be set appropriately' do
      @config.should =~ /^clientalivecountmax 0\r*$/
    end

    it 'CCE-14491-5 Use appropriate ciphers for SSH' do
      allowed_ciphers = %w(
        aes128-ctr
        aes192-ctr
        aes256-ctr
      )
      @config.should =~ /^ciphers #{allowed_ciphers.join(',')}\r*$/
    end

    it 'CCE-14716-5 Users should not be allowed to set env options' do
      @config.should =~ /^permituserenvironment no\r*$/
    end
  end

  describe 'obscurity' do
    it 'should hide patch level' do
      @config.should =~ /^showpatchlevel no\r*$/
    end
  end
end
