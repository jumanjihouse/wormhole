# encoding: utf-8
require 'spec_helper'

describe 'jumanjiman/wormhole' do
  before :context do
    @docker_version = Docker.version['Version']
    if Gem::Version.new(@docker_version) >= Gem::Version.new('0.9')
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

  describe 'image properties' do
    before :example do
      @config = @image.json['config']
    end

    it 'should expose ssh port and only ssh port' do
      @config['ExposedPorts'].keys.should =~ ['22/tcp']
    end

    volumes = %w(
      /home/user
      /media/state/etc/ssh
    )

    volumes.each do |vol|
      it "should have volume #{vol}" do
        @config['Volumes'].keys.include?(vol).should be_truthy
      end
    end
  end
end
