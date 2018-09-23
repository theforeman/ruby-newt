#!/usr/bin/env ruby

require 'rubygems'
require 'newt'

begin
  SCALE_EMPTY = Newt::COLORSET_CUSTOM 1
  SCALE_FULL  = Newt::COLORSET_CUSTOM 2

  Newt::Screen.new
  Newt::Screen.set_color(SCALE_EMPTY, 'yellow', 'cyan')
  Newt::Screen.set_color(SCALE_FULL,  'black', 'red')
  Newt::Screen.centered_window(20, 8, 'Scale')

  s = Newt::Scale.new(1, 1, 18, 100)
  s.set(50)
  s.set_colors(SCALE_EMPTY, SCALE_FULL)

  b = Newt::Button.new(6, 4, 'Exit')

  f = Newt::Form.new
  f.add(s, b)

  f.run
ensure
  Newt::Screen.finish
end
