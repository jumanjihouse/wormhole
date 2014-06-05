# vim: set ts=2 sw=2 ai et:

# Does the current user have root privileges?
#
# @return [Boolean] true if user can exercise root privileges;
#   false if user does not have privileges OR we're on a
#   non-posix platform
def got_root?
  # attempt to exercise privilege
  Process::Sys.setuid(0)
  true
rescue Errno::EPERM
  false
end

abort 'Must not run as root' if got_root?

require 'bundler/setup'
require 'bundler/settings'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'
require 'fileutils'

task default: [:help]

desc 'Display the list of available rake tasks'
task :help do
  system('rake -T')
end

RuboCop::RakeTask.new

desc 'Run rspec tests'
RSpec::Core::RakeTask.new(:spec_standalone)
