# encoding: utf-8
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

# Run unit tests before functional tests.
desc 'Run rspec tests'
task spec_standalone: [
  :validate_bundle,
  :unit,
  :functional,
]

RSpec::Core::RakeTask.new(:unit) do |t|
  t.pattern = 'spec/unit/**/*_spec.rb'
end

RSpec::Core::RakeTask.new(:functional) do |t|
  t.pattern = 'spec/functional/**/*_spec.rb'
end

task :validate_bundle do
  begin
    require 'docker'
    Docker.validate_version!
  rescue Docker::Error::VersionError
    abort '[ERROR] docker-api gem is incompatible with this version of Docker'
  end
end
