#!/usr/bin/env ruby

require 'rubygems'
require "newt"

COLORS = {
  borderFg:     "yellow", borderBg:     "cyan",
  windowFg:     "black",  windowBg:     "cyan",
  titleFg:      "black",  titleBg:      "cyan",
  listboxFg:    "black",  listboxBg:    "cyan",
  actListboxFg: "black",  actListboxBg: "red",
  buttonFg:     "white",  buttonBg:     "blue"
}

begin

  Newt::Screen.new
  Newt::Screen.set_colors(COLORS)

  l1 = Newt::Listbox.new(1, 1, 10, Newt::FLAG_SCROLL)
  1.upto(20) do |i|
	l1.append("item #{i}", i)
  end

  b = Newt::Button.new(1, 12, "Exit")

  f = Newt::Form.new
  f.add(l1, b)

  f.run()

ensure
  Newt::Screen.finish
end
