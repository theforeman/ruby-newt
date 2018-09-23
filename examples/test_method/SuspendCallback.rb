#!/usr/bin/env ruby
# rubocop:disable Style/GlobalVars

require 'rubygems'
require 'newt'

$suspend_called = false
$callback_data = nil

def global_callback(data)
  $suspend_called = true
  $callback_data = data
end

begin
  Newt::Screen.new
  Newt::Screen.suspend_callback(:global_callback, 'Hello World!')
  Newt::Screen.centered_window(20, 8, 'Suspend Callback')

  l = Newt::Label.new(6, 1, 'Press ^Z')
  b = Newt::Button.new(6, 3, 'Exit')

  f = Newt::Form.new
  f.add(l, b)

  f.run
ensure
  Newt::Screen.finish
end

puts "suspend_called: #{$suspend_called}"
puts "callback_data: #{$callback_data}"
# rubocop:enable Style/GlobalVars
