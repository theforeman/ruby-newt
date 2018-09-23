#!/usr/bin/env ruby

require 'rubygems'
require 'newt'

begin
  TEXTBOX_NORMAL = Newt::COLORSET_CUSTOM 1
  TEXTBOX_ACTIVE = Newt::COLORSET_CUSTOM 2

  Newt::Screen.new
  Newt::Screen.set_color(TEXTBOX_NORMAL, 'black', 'red')
  Newt::Screen.set_color(TEXTBOX_ACTIVE, 'white', 'red')
  Newt::Screen.centered_window(20, 10, 'Textbox')

  t = Newt::Textbox.new(1, 1, 18, 3, Newt::FLAG_WRAP)
  t.set_colors(TEXTBOX_NORMAL, TEXTBOX_ACTIVE)
  t.set_text("Line1\nLine2\nLine3")
  t.set_height(20)

  b = Newt::Button.new(6, 6, 'Exit')
  f = Newt::Form.new
  f.add(t, b)

  f.run
ensure
  Newt::Screen.finish
end
