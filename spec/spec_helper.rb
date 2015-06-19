# encoding: utf-8
require 'minitest'
require 'mocha/setup'
require 'English'
require 'docker'
require 'tempfile'
require 'pp'
require 'net/ssh'

def debug?
  ENV.key?('DEBUG') || ENV.key?('CI')
end

def debug(str)
  STDERR.puts str if debug?
end

def run_command(str)
  debug? ? system(str) : `#{str}`
end

# What external port is mapped to container's sshd?
#
# @return [Integer] such as 41953
def ssh_port_mapping(cid)
  `docker port #{cid} 22/tcp`.split(':').last.to_i
end

# Does this system have systemd?
def systemd?
  system('which systemctl 2> /dev/null')
end

# Silly name for fake user.
#
# @return [String]
def handle
  'booga'
end

# rubocop:disable MethodLength,AbcSize,CyclomaticComplexity
def ssh(cmd, port = @port, privkey = @privkey)
  abort '[ERROR] must provide command' unless cmd
  abort '[ERROR] must provide port' unless port
  abort '[ERROR] must provide path to privkey' unless privkey

  STDERR.puts "[INFO] net-ssh version #{Net::SSH::Version::CURRENT}" if debug?

  host = 'localhost'
  username = 'user'
  session = Net::SSH.start(
    host,
    port: port,
    username: username,
    keys: [privkey],
    paranoid: false,
    auth_methods: ['publickey'],
    user_known_hosts_file: '/dev/null',
  )
  res = session.exec(cmd)
  session.close
  res
rescue Net::SSH::HostKeyMismatch => e
  debug '[INFO] got hostkey mismatch'
  e.remember_host!
  retry
rescue Net::SSH::AuthenticationFailed => e
  debug "[WARN] ruby net-ssh: #{e.message}"
  debug '[INFO] Falling back to system ssh'
  ssh_opts = %W(
    -o StrictHostKeyChecking=no
    -o UserKnownHostsFile=/dev/null
    -i #{privkey}
    -p #{port}
  )
  s = `ssh #{ssh_opts.join(' ')} #{username}@#{host} "#{cmd}" 2> /dev/null`
  # scrub method only appears in ruby 2.1+
  unless s.valid_encoding?
    s = s.encode('UTF-16be', invalid: :replace, replace: '?').encode('UTF-8')
  end
  s
end
# rubocop:enable MethodLength,AbcSize,CyclomaticComplexity

# Ugh, use global to persist value across contexts.
# Create temp ssh dir and temp ssh keypair.
ssh_dir = Dir.mktmpdir
key = Tempfile.new('id_rsa', ssh_dir)
privkey = key.path
key.close!
pubkey = privkey + '.pub'

RSpec.configure do |c|
  c.mock_with :mocha
  c.color = true
  c.formatter = 'doc'

  # Allow both "should" and "expect" syntax.
  # https://www.relishapp.com/rspec/rspec-expectations/docs/syntax-configuration
  c.expect_with :rspec do |e|
    e.syntax = [:should, :expect]
  end

  # Fail overall as soon as first test fails.
  # Fail fast to reduce duration of test runs.
  # IOW get out of the way so that the next pull request gets tested.
  c.fail_fast = true

  # show times for 10 slowest examples (unless there are failed examples)
  c.profile_examples = true if debug?

  # Number of seconds between garbage collections.
  # 0.0 means do not manage the GC.
  #
  # Caution:
  # If you set this too high, resident set size (RSS) will balloon
  # on travis and lead to longer diffspec duration due to swapping.
  c.add_setting :gc_interval, default: 0.0

  # Override default seconds between garbage collections.
  #
  # In general, you should tune this to balance:
  # * Minimize run-time of the GC.
  # * Avoid letting RSS reach amount of available RAM.
  if RUBY_VERSION =~ /^1/
    c.gc_interval = 2.0
  else
    c.gc_interval = 1.75
  end

  # Make it easy for spec tests to find fixtures.
  c.add_setting :fixture_path, default: nil
  c.fixture_path = File.expand_path(File.join(__FILE__, '..', 'fixtures'))

  # Start a container and make it available for tests.
  c.before :suite do
    run_command "ssh-keygen -q -t rsa -b 1024 -N '' -f #{privkey}"
    content = File.read(pubkey).chomp
    run_command "./build.sh #{handle} \"#{content}\""

    unless systemd?
      # The build script uses systemd to start the container, so
      # we have to kludge on test host that doesn't have systemd.
      # rubocop:disable LineLength
      `docker run -d -t -m 512m --volumes-from #{handle}-data -P -h wormhole.example.com --name #{handle} jumanjiman/wormhole`
      # rubocop:enable LineLength
    end
    sleep 5
  end

  # Instance variables can only be set in :context and :example,
  # not :suite.
  c.before :context do
    @app = Docker::Container.get(handle)
    @data = Docker::Container.get("#{handle}-data")
    @port = ssh_port_mapping(handle)
    @privkey = privkey
    @pubkey = pubkey
  end

  # Clean up.
  # @note CircleCI does not allow to delete containers, so
  # we need to ensure container stays up through all tests.
  c.after :suite do
    unless ENV['CIRCLECI']
      File.delete privkey, pubkey
      if systemd?
        path = "#{handle}-data.tar"
        File.delete(path) if File.exist?(path)
        run_command "./destroy.sh #{handle} 2> /dev/null"
      else
        app = Docker::Container.get(handle)
        app.kill
        app.delete(true)

        data = Docker::Container.get("#{handle}-data")
        data.delete(true)
      end
    end
  end

  # Collect and report stats from the Ruby garbage collector.
  #
  # @see http://labs.goclio.com/tuning-ruby-garbage-collection-for-rspec/
  # @see http://37signals.com/svn/posts/2742-the-road-to-faster-tests
  # @see http://fredwu.me/post/60441991350/protip-ruby-devs-please-tweak-your-gc-settings-for
  unless RUBY_VERSION =~ /^1/ && !debug?
    # Start with initial values.
    gc_stat = GC.stat.dup

    # After each test, update the max values.
    c.after :each do
      GC.stat.each { |k, v| gc_stat[k] = [gc_stat[k], v].max }
    end

    # After all tests have run, pretty print the values.
    c.after :suite do
      2.times { puts '' }
      puts 'Garbage collector stats (see spec_helper.rb for helpful links)'
      puts '--------------------------------------------------------------'
      pp gc_stat
    end
  end
end
