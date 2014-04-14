# encoding: utf-8
require 'spec_helper'
require 'friction'
require 'stringio'

# Monkey-patch kernel to capture stdout
# as workaround for friction gem. bleh.
#
# @todo submit PR against friction.
module Kernel
  def capture_stdout
    real_out, out = $stdout, StringIO.new
    $stdout = out
    yield
    return out.string
  ensure
    $stdout = real_out
  end
end

describe 'contributor friction' do
  it 'there should not be any' do
    out = capture_stdout { Friction.run! }
    out.should =~ /Everything is in order/
  end
end
