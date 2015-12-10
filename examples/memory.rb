#!/usr/bin/env ruby

require 'rubygems'
require "newt"

def cleanup
  Newt::Screen.finish
end

Newt::Screen.new
Signal.trap("INT") { cleanup }

(1..10).each do
  form = Newt::Form.new
  button1 = Newt::Button.new(3, 1, "Exit")
  button2 = Newt::Button.new(18, 1, "Update")
  form.add(button1, button2)
  Newt::Screen.refresh
  GC.start
end

cleanup
