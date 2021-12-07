#!/usr/bin/env ruby

require 'rubygems'
require 'newt'

begin
  Newt::Screen.new

  ct = Newt::CheckboxTree.new(1, 10, 4, Newt::FLAG_SCROLL)
  ct.add('Checkbox1', 1, 0, Newt::ARG_APPEND)
  ct.add('Checkbox2', 2, 0, Newt::ARG_APPEND)
  ct.add('Checkbox3', 3, 0, Newt::ARG_APPEND)
  ct.add('Checkbox4', 4, 0, 2, Newt::ARG_APPEND)
  ct.add('Checkbox5', 5, 0, 2, Newt::ARG_APPEND)
  b = Newt::Button.new(1, 15, 'Exit')

  ct.set_width(30)
  ct.set_entry(2, 'ITEM2')
  f = Newt::Form.new
  f.add(ct, b)

  f.run
  selection = ct.get_selection
ensure
  Newt::Screen.finish
end

p selection
