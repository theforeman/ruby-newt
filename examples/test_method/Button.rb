#!/usr/bin/env ruby

require 'rubygems'
require 'newt'

begin
  Newt::Screen.new
  Newt::Screen.centered_window(20, 15, 'Button')

  b1 = Newt::Button.new(1, 1, 'Button1')
  b2 = Newt::Button.new(1, 6, 'Button2')

  b = Newt::Button.new(1, 11, 'Exit')

  f = Newt::Form.new
  f.add(b1, b2, b)

  f.run
ensure
  Newt::Screen.finish
end
