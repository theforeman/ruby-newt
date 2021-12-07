#!/usr/bin/env ruby

require 'rubygems'
require 'newt'

begin
  Newt::Screen.new

  l1 = Newt::Listbox.new(1, 1, 10, Newt::FLAG_SCROLL)
  1.upto(20) do |i|
    l1.append("item #{i}", i)
  end
  l1.delete(5)
  l1.insert('**INSERTED**', 100, 3)
  l1.set(5, '**CHANGED**')
  l1.set_current(3)
  l1.select(l1.get_current, Newt::FLAGS_SET)
  l1.select(9, Newt::FLAGS_SET)
  l1.set_current_by_key(11)
  l1.set_width(20)

  b = Newt::Button.new(1, 12, 'Exit')

  f = Newt::Form.new
  f.add(l1, b)

  f.run
  item_count = l1.item_count
ensure
  Newt::Screen.finish
end

puts "number of list items = #{item_count}"
