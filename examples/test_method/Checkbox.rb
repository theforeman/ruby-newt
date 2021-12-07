#!/usr/bin/env ruby

require 'rubygems'
require 'newt'

begin
  Newt::Screen.new
  Newt::Screen.centered_window(20, 11, 'Checkbox')

  cb1 = Newt::Checkbox.new(1, 1, 'Checkbox1', 'A', nil)
  cb2 = Newt::Checkbox.new(1, 2, 'Checkbox2', '', '+')
  cb3 = Newt::Checkbox.new(1, 3, 'Checkbox3')
  cb4 = Newt::Checkbox.new(1, 4, 'Checkbox4', nil, '')
  cb5 = Newt::Checkbox.new(1, 5, 'Checkbox5')
  b = Newt::Button.new(6, 7, 'Exit')

  cb3.set('@')
  cb5.set_flags(Newt::FLAG_DISABLED, Newt::FLAGS_SET)
  f = Newt::Form.new
  f.add(cb1, cb2, cb3, cb4, cb5, b)

  f.run

  cb1 = cb1.get
  cb2 = cb2.get
  cb3 = cb3.get
  cb4 = cb4.get
  cb5 = cb5.get
ensure
  Newt::Screen.finish
end

p cb1, cb2, cb3, cb4, cb5
