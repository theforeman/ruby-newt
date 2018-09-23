#!/usr/bin/env ruby

require 'rubygems'
require 'newt'

begin
  Newt::Screen.new
  Newt::Screen.centered_window(20, 8, 'RadioButton')

  rb1 = Newt::RadioButton.new(1, 1, 'Button1', 1)
  rb2 = Newt::RadioButton.new(1, 2, 'Button2', 0, rb1)

  b = Newt::Button.new(6, 4, 'Exit')

  f = Newt::Form.new
  f.add(rb1, rb2, b)

  f.run
ensure
  Newt::Screen.finish
end

puts "selected: #{rb1.get_current}"
