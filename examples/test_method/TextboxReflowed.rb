#!/usr/bin/env ruby

require 'rubygems'
require 'newt'

begin
  Newt::Screen.new
  Newt::Screen.centered_window(20, 10, 'TextboxReflowed')

  text = "Line1 Line1 Line1 Line1 Line1 Line1 Line1 Line1 \nLine2"
  t = Newt::TextboxReflowed.new(1, 1, text, 18, 0, 0, 0)

  b = Newt::Button.new(6, 6, 'Exit')
  f = Newt::Form.new
  f.add(t, b)

  f.run
ensure
  Newt::Screen.finish
end
