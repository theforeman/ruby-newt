#!/usr/bin/env ruby

require 'rubygems'
require "newt"

begin

  Newt::Screen.new

  cb1 = Newt::Checkbox.new(1, 10, "Button1", 'A', nil)
  cb2 = Newt::Checkbox.new(1, 11, "Button2", '', '+')
  cb3 = Newt::Checkbox.new(1, 12, "Button3", nil, nil)
  cb4 = Newt::Checkbox.new(1, 13, "Button4", nil, "")
  b = Newt::Button.new(1, 14, "Exit")

  begin
    Newt::Checkbox.new(1, 1)
    raise "ArgumentError not raised"
  rescue ArgumentError => e
  end

  begin
    Newt::Checkbox.new(1, 1, "", nil, nil, nil);
    raise "ArgumentError not raised"
  rescue ArgumentError => e
  end

  f = Newt::Form.new
  f.add(cb1, cb2, cb3, cb4, b)

  f.run()

  v1, v2, v3, v4 = cb1.get, cb2.get, cb3.get, cb4.get
ensure
  Newt::Screen.finish
end

p v1, v2, v3, v4
