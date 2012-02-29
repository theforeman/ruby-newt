#!/usr/bin/env ruby

require "newt"

begin

  Newt::Screen.new
  #Newt::Screen.init
  #Newt::Screen.cls

  e = Newt::Entry.new(1, 1, "Entry", 10, 0)
  e.set("New New", true)
  #e.set("New New", false)
  #e.set("New New", 0)

  b = Newt::Button.new(10, 13, "Exit")

  f = Newt::Form.new
  f.add(e, b)

  f.run()

ensure
  Newt::Screen.finish
end
