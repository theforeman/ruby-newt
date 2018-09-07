#!/usr/bin/env ruby

require 'rubygems'
require "newt"

begin

  Newt::Screen.new

  ct1 = Newt::CheckboxTreeMulti.new(1, 10, 1, " ab", Newt::FLAG_SCROLL)
  ct1.add("Checkbox1", 1, 1, Newt::ARG_APPEND)
  ct2 = Newt::CheckboxTreeMulti.new(1, 11, 1, "", Newt::FLAG_SCROLL)
  ct2.add("Checkbox2", 1, 1, Newt::ARG_APPEND)
  b = Newt::Button.new(1, 12, "Exit")

  f = Newt::Form.new
  f.add(ct1, ct2, b)

  f.run()

ensure
  Newt::Screen.finish
end
