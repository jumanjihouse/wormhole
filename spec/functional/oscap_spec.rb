# encoding: utf-8
require 'spec_helper'

describe 'SCAP secure configuration checks (slow test)' do
  it 'should pass all tests' do
    cmds = '
      cd /usr/share/xml/scap/ssg/fedora/
      oscap xccdf eval --profile xccdf_wormhole_profile_devenv \
        --tailoring-file wormhole-devenv-xccdf.xml \
        --cpe ssg-fedora-cpe-dictionary.xml \
        ssg-fedora-xccdf.xml && echo OK
    '
    ssh(cmds).should match(/^OK$/)
  end

  # Why does oscap skip this check?
  it '/etc/securetty should be a zero-size file' do
    cmd = "stat --format='%s' /etc/securetty"
    ssh(cmd).should match(/^0$/)
  end
end
