#!/usr/bin/env ruby

require 'rubygems'
require "newt"

begin
  LABEL_COLOR1 = Newt::COLORSET_CUSTOM 1
  LABEL_COLOR2 = Newt::COLORSET_CUSTOM 2

  Newt::Screen.new
  Newt::Screen.set_color(LABEL_COLOR1, "green", "cyan")
  Newt::Screen.set_color(LABEL_COLOR2, "red", "black")

  l1 = Newt::Label.new(1, 5, "Label1")
  l1.set_colors(LABEL_COLOR1)
  l2 = Newt::Label.new(1, 9, "Label2")
  l2.set_colors(LABEL_COLOR2)

  b = Newt::Button.new(1, 13, "Exit")

  f = Newt::Form.new
  f.add(l1, l2, b)

  f.run()

ensure
  Newt::Screen.finish
end
