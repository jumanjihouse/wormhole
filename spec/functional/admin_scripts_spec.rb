# encoding: utf-8
require 'spec_helper'

describe 'admin scripts' do
  describe "given user handle=\"#{handle}\"" do
    it 'everybody knows pubkey' do
      File.exist?(@pubkey).should be_truthy
    end

    it "#{handle} knows privkey" do
      File.exist?(@privkey).should be_truthy
    end
  end

  describe '`build.sh $handle "$pubkey"` creates wormhole from 2 containers' do
    describe "\"#{handle}-data\" is a persistent read-write container" do
      before :context do
        @config = @data.json['Config']
        @hostconfig = @data.json['HostConfig']
        @state  = @data.json['State']
        pp @data.json unless @config && @state
      end

      it 'should exist' do
        @data.should_not be_nil
      end

      it 'should be stopped' do
        @state['Running'].should be_falsy
      end

      it 'should be created from busybox' do
        id = @config['Image'].split(':').first
        id.should == 'busybox'
      end

      it 'should export /home/user volume read-write' do
        @config['Volumes'].keys.include?('/home/user').should be_truthy
        @data.json['VolumesRW'].key?('/home/user').should be_truthy
        @data.json['VolumesRW']['/home/user'].should be_truthy
      end

      it 'should export /media/state/etc/ssh volume read-write' do
        @data.json['VolumesRW'].key?('/media/state/etc/ssh').should be_truthy
        @data.json['VolumesRW']['/media/state/etc/ssh'].should be_truthy
      end

      it 'should not mount any volumes' do
        @config['Volumes'].each { |_k, v| v.should be_empty }
        @hostconfig['VolumesFrom'].should be_nil
      end
    end

    describe "\"#{handle}\" is a read-only app container" do
      before :context do
        @config = @app.json['Config']
        @hostconfig = @app.json['HostConfig']
        @state  = @app.json['State']
        pp @app.json unless @config && @state
      end

      it 'should exist' do
        @app.should_not be_nil
      end

      it 'should be running' do
        @state['Running'].should be_truthy
      end

      it 'should run unprivileged' do
        priv = @app.json['HostConfig']['Privileged']
        priv.should be_falsy
      end

      it 'should be created from jumanjiman/wormhole' do
        id = @config['Image'].split(':').first
        id.should == 'jumanjiman/wormhole'
      end

      it "should use volumes from #{handle}-data" do
        @hostconfig['VolumesFrom'].should =~ ["#{handle}-data"]
      end

      it 'should have hostname wormhole.example.com' do
        fqdn = @config['Hostname'] + '.' + @config['Domainname']
        fqdn.should == 'wormhole.example.com'
      end

      it 'should be limited to 512 MiB RAM' do
        pending 'circleci does not support limits' if ENV['CIRCLECI']
        limit = 512 * 1024 * 1024
        @config['Memory'].should == limit
      end

      it '`docker logs` should show sshd running on sshd port' do
        sleep 2 # allow for startup time
        output = `docker logs #{handle}`
        output.should =~ /Server listening on 0.0.0.0 port 22/
      end

      it 'should expose internal sshd port and only sshd port' do
        @app.json['NetworkSettings']['Ports'].keys.should =~ ['22/tcp']
      end

      it 'should map internal sshd port to an outside ephemeral port' do
        port = @app.json['NetworkSettings']['Ports']['22/tcp'][0]['HostPort']
        port.to_i.should > 1024
      end
    end
  end
end
