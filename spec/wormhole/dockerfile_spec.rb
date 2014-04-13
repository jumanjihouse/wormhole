# encoding: utf-8
require 'spec_helper'
require 'pp'

describe 'jumanjiman/wormhole' do
  before :all do
    @docker_version = Docker.version['Version']
    if @docker_version >= '0.9'
      key, repo = 'RepoTags', 'jumanjiman/wormhole:latest'
      @image = Docker::Image.all.find { |i| i.info[key].include?(repo) }
    else
      key, repo = 'Repository', 'jumanjiman/wormhole'
      @image = Docker::Image.all.find { |i| i.info[key] == repo }
    end
    pp Docker::Image.all unless @image
  end

  describe 'image' do
    it 'should be available' do
      @image.should_not be_nil
    end
  end

  describe 'config' do
    before :each do
      @config = @image.json['config']
    end

    it 'should expose ssh port and only ssh port' do
      @config['ExposedPorts'].keys.should =~ ['22/tcp']
    end

    it 'should run sshd with logging' do
      @config['Cmd'].include?('/usr/sbin/sshd -D -e').should be_true
    end
  end
end
