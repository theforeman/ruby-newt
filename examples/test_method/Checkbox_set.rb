#!/usr/bin/env ruby

require 'rubygems'
require "newt"

begin

  Newt::Screen.new

  cb1 = Newt::Checkbox.new(1, 10, "Button1", '', nil)
  cb2 = Newt::Checkbox.new(1, 11, "Button2", nil, nil)
  cb3 = Newt::Checkbox.new(1, 12, "Button3", 'A', nil)
  cb4 = Newt::Checkbox.new(1, 13, "Button4", nil, "XO")
  cb5 = Newt::Checkbox.new(1, 14, "Button5", nil, "XO")
  cb6 = Newt::Checkbox.new(1, 15, "Button6", '', nil)
  cb1.set('***'); cb2.set('**'); cb3.set('*'); cb4.set('O'); cb5.set('A')
  b = Newt::Button.new(1, 16, "Exit")

  f = Newt::Form.new
  f.add(cb1, cb2, cb3, cb4, cb5, cb6, b)

  f.run()

  v1, v2, v3, v4, v5, v6 = cb1.get, cb2.get, cb3.get, cb4.get, cb5.get, cb6.get
ensure
  Newt::Screen.finish
end

p v1, v2, v3, v4, v5, v6
