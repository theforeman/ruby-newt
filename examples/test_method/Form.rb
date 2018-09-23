#!/usr/bin/env ruby

require 'rubygems'
require 'newt'

begin
  Newt::Screen.new

  b1 = Newt::Button.new(1, 5, 'Button1')
  b2 = Newt::Button.new(1, 9, 'Button2')

  b = Newt::Button.new(1, 13, 'Exit')

  f = Newt::Form.new
  f.set_background(7)
  f.set_height(20)
  f.set_width(50)
  f.add(b1, b2, b)

  f.run
ensure
  Newt::Screen.finish
end
