# encoding: utf-8
require 'spec_helper'

# Silly name for fake user.
# We use top-scope to allow show in rspec subject.
handle = 'booga'

describe 'admin scripts' do
  before :all do
    # Ensure ssh dir exists.
    ssh_dir = File.join(Dir.home, '.ssh')
    Dir.mkdir(ssh_dir, 0700) unless Dir.exist?(ssh_dir)

    # Create temp ssh keypair.
    key = Tempfile.new('id_rsa', ssh_dir)
    @privkey = key.path
    @pubkey = @privkey + '.pub'
    key.close!
    system "ssh-keygen -q -t rsa -b 1024 -N '' -f #{@privkey}"

    pubkey = File.read(@pubkey)
    %x(./build.sh #{handle} "#{pubkey}" 2> /dev/null)
    @app = Docker::Container.get("#{handle}-run")
    @data = Docker::Container.get("#{handle}-data")
  end

  describe "given user handle=\"#{handle}\"" do
    it 'everybody knows pubkey' do
      File.exist?(@pubkey).should be_true
    end

    it "#{handle} knows privkey" do
      File.exist?(@privkey).should be_true
    end
  end

  describe '`build.sh $handle "$pubkey"` creates wormhole from 2 containers' do
    describe "\"#{handle}-data\" is a persistent read-write container" do
      before :all do
        @config = @data.json['Config']
        @state  = @data.json['State']
        pp @data.json unless @config && @state
      end

      it 'should exist' do
        @data.should_not be_nil
      end

      it 'should be stopped' do
        @state['Running'].should be_false
      end

      it 'should be created from busybox' do
        id = @config['Image'].split(':').first
        id.should == 'busybox'
      end

      it 'should export /home/user volume read-write' do
        @config['Volumes'].keys.include?('/home/user').should be_true
        @data.json['VolumesRW'].key?('/home/user').should be_true
        @data.json['VolumesRW']['/home/user'].should be_true
      end

      it 'should export /media/state/etc/ssh volume read-write' do
        @data.json['VolumesRW'].key?('/media/state/etc/ssh').should be_true
        @data.json['VolumesRW']['/media/state/etc/ssh'].should be_true
      end

      it 'should not mount any volumes' do
        @config['Volumes'].each { |_k, v| v.should be_empty }
        @config['VolumesFrom'].should be_empty
      end
    end

    describe "\"#{handle}-run\" is a read-only app container" do
      before :all do
        @config = @app.json['Config']
        @state  = @app.json['State']
        pp @app.json unless @config && @state
      end

      it 'should exist' do
        @app.should_not be_nil
      end

      it 'should be running' do
        @state['Running'].should be_true
      end

      it 'should run unprivileged' do
        priv = @app.json['HostConfig']['Privileged']
        priv.should be_false
      end

      it 'should be created from jumanjiman/wormhole' do
        id = @config['Image'].split(':').first
        id.should == 'jumanjiman/wormhole'
      end

      it "should use volumes from #{handle}-data" do
        @config['VolumesFrom'].should == "#{handle}-data"
      end

      it 'should have hostname wormhole.example.com' do
        fqdn = @config['Hostname'] + '.' + @config['Domainname']
        fqdn.should == 'wormhole.example.com'
      end

      it 'should be limited to 512 MiB RAM' do
        limit = 512 * 1024 * 1024
        @config['Memory'].should == limit
      end

      it 'should run sshd and only sshd' do
        @config['Cmd'].include?('/usr/sbin/sshd -D -e').should be_true
      end

      it '`docker logs` should show sshd running on sshd port' do
        sleep 2 # allow for startup time
        output = %x(docker logs #{@app.json['ID']})
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

  after :all do
    File.delete @privkey, @pubkey
    @app.kill
    @app.delete(true)
    @data.delete(true)
  end
end
