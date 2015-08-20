#!/usr/bin/env ruby
require 'rubygems'
require "newt"

def cleanup
  Newt::Screen.finish
end

Newt::Screen.new
Signal.trap("INT") { cleanup }

(1..10).each do
  f = Newt::Form.new
  b1 = Newt::Button.new(3, 1, "Exit")
  b2 = Newt::Button.new(18, 1, "Update")
  f.add(b1, b2)
  Newt::Screen.refresh
  GC.start
end

cleanup
