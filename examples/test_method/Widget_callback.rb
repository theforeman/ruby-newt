#!/usr/bin/env ruby
# rubocop:disable Style/GlobalVars

require 'rubygems'
require 'newt'

$cb1_called = false
$cb1_widget = nil
$cb1_data = nil

$cb2_called = false
$cb2_widget = nil
$cb2_data = nil

$cb3_called = false
$cb3_widget = nil
$cb3_data = nil

def callme(w, data)
  $cb1_called = true
  $cb1_widget = w
  $cb1_data = data
end

class Receiver
  attr_reader :cb
  def initialize
    @cb = Newt::Checkbox.new(1, 12, 'Checkbox3')
    @cb.callback(:callme, 'Hello Receiver!')
  end

  def callme(w, data)
    $cb3_called = true
    $cb3_widget = w
    $cb3_data = data
  end
end

begin
  Newt::Screen.new

  cb1 = Newt::Checkbox.new(1, 10, 'Checkbox1')
  cb1.callback(:callme, 'Hello World!')

  cb2 = Newt::Checkbox.new(1, 11, 'Checkbox2')
  cb2.callback(proc { |w, data|
    $cb2_called = true
    $cb2_widget = w
    $cb2_data = data
  }, 'Hello Proc!')

  cb_receiver = Receiver.new
  b = Newt::Button.new(1, 14, 'Exit')

  f = Newt::Form.new
  f.add(cb1, cb2, cb_receiver.cb, b)

  f.run
ensure
  Newt::Screen.finish
end

puts "$cb1_called: #{$cb1_called}"
puts "$cb1_widget: #{$cb1_widget}"
puts "$cb1_data: #{$cb1_data}"
puts

puts "$cb2_called: #{$cb2_called}"
puts "$cb2_widget: #{$cb2_widget}"
puts "$cb2_data: #{$cb2_data}"
puts

puts "$cb3_called: #{$cb3_called}"
puts "$cb3_widget: #{$cb3_widget}"
puts "$cb3_data: #{$cb3_data}"
# rubocop:enable Style/GlobalVars
