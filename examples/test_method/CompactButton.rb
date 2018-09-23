#!/usr/bin/env ruby

require 'rubygems'
require 'newt'

begin
  Newt::Screen.new
  Newt::Screen.centered_window(20, 10, 'CompactButton')

  b1 = Newt::CompactButton.new(1, 1, 'Button1')
  b2 = Newt::CompactButton.new(1, 3, 'Button2')

  b = Newt::Button.new(5, 5, 'Exit')

  f = Newt::Form.new
  f.add(b1, b2, b)

  f.run
ensure
  Newt::Screen.finish
end
