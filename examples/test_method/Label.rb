#!/usr/bin/env ruby

require 'rubygems'
require 'newt'

begin
  LABEL_COLOR = Newt::COLORSET_CUSTOM 1

  Newt::Screen.new
  Newt::Screen.set_color(LABEL_COLOR, 'green', 'cyan')
  Newt::Screen.centered_window(18, 10, 'Label')

  l1 = Newt::Label.new(1, 1, 'Label1')
  l2 = Newt::Label.new(1, 3, 'Label2')
  l2.set_text('New Label')
  l2.set_colors(LABEL_COLOR)

  b = Newt::Button.new(5, 5, 'Exit')

  f = Newt::Form.new
  f.add(l1, l2, b)

  f.run
ensure
  Newt::Screen.finish
end
