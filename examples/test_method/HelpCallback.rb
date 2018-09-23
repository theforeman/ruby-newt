#!/usr/bin/env ruby
# rubocop:disable Style/GlobalVars

require 'rubygems'
require 'newt'

$help_called = false
$help_form = nil
$help_data = nil

def global_callback(form, data)
  $help_called = true
  $help_form = form
  $help_data = data

  Newt::Screen.centered_window(41, 6, 'Help')
  l1 = Newt::Label.new(1,  1, "Form = #{form}")
  l2 = Newt::Label.new(1,  2, "Data = #{data}")
  l3 = Newt::Label.new(15, 4, 'Hit Escape')

  f = Newt::Form.new
  f.add(l1, l2, l3)
  f.add_hotkey("\e".ord)
  f.run

  Newt::Screen.pop_window
end

begin
  Newt::Screen.new
  Newt::Screen.help_callback(:global_callback)
  Newt::Screen.centered_window(20, 8, 'Help Callback')

  l = Newt::Label.new(6, 1, 'Press F1')
  b = Newt::Button.new(6, 3, 'Exit')
  f = Newt::Form.new(nil, 'Hello World!')
  f.add(l, b)

  f.run
ensure
  Newt::Screen.finish
end

puts "help_called: #{$help_called}"
puts "help_form: #{$help_form}"
puts "help_data: #{$help_data}"
puts "(help_form == f) ? #{$help_form == f}"
# rubocop:enable Style/GlobalVars
