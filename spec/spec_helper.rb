# encoding: utf-8
require 'minitest'
require 'mocha/setup'
require 'English'
require 'docker'
require 'tempfile'
require 'pp'

RSpec.configure do |c|
  c.mock_with 'mocha'
  c.color = true
  c.formatter = 'doc'

  # Fail overall as soon as first test fails.
  # Fail fast to reduce duration of test runs.
  # IOW get out of the way so that the next pull request gets tested.
  c.fail_fast = true

  # show times for 10 slowest examples (unless there are failed examples)
  c.profile_examples = true

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

  # Collect and report stats from the Ruby garbage collector.
  #
  # rubocop:disable LineLength
  # @see http://labs.goclio.com/tuning-ruby-garbage-collection-for-rspec/
  # @see http://37signals.com/svn/posts/2742-the-road-to-faster-tests
  # @see http://fredwu.me/post/60441991350/protip-ruby-devs-please-tweak-your-gc-settings-for
  # rubocop:enable LineLength
  unless RUBY_VERSION =~ /^1/
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
