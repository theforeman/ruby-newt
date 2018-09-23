#!/usr/bin/env ruby
require 'rubygems'
require 'newt'

begin
  Newt::Screen.new
  Newt::Screen.centered_window(45, 10, 'Cursor Test')

  l = Newt::Listbox.new(5, 1, 5)
  1.upto(3) do |i|
    l.append("item #{i}", i)
  end

  b1 = Newt::Button.new(2, 5, 'Cursor On')
  b2 = Newt::Button.new(17, 5, 'Cursor Off')
  b3 = Newt::Button.new(33, 5, 'Exit')

  f = Newt::Form.new
  f.add(l, b1, b2, b3)

  loop do
    case f.run
    when b1 then Newt::Screen.cursor_on
    when b2 then Newt::Screen.cursor_off
    else break
    end
  end
ensure
  Newt::Screen.finish
end
