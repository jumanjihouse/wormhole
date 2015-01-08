# encoding: utf-8
require 'spec_helper'

describe 'jumanjiman/wormhole' do
  it 'should use correct docker API version' do
    Docker.validate_version!.should be_truthy
  end

  it 'image should be available' do
    Docker::Image.exist?('jumanjiman/wormhole').should be_truthy
  end

  describe 'image properties' do
    before(:each) do
      @config = Docker::Image.get('jumanjiman/wormhole').info['Config']
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
