#!/usr/bin/env ruby

require 'rubygems'
require "newt"

begin

  Newt::Screen.new

  b1 = Newt::Button.new(1, 5, "Button1")
  b2 = Newt::Button.new(1, 9, "Button2")

  b = Newt::Button.new(1, 13, "Exit")

  f = Newt::Form.new
  f.add_hotkey(?\e.ord)
  f.add(b1, b2, b)

  rv = f.run()

ensure
  Newt::Screen.finish
end

puts rv.inspect
puts "Button1" if rv == b1
puts "Button2" if b2 == rv
puts "Exit" if rv == b
puts "Escape" if (rv.reason == Newt::EXIT_HOTKEY && rv.key == ?\e.ord)
