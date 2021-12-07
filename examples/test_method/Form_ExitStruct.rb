#!/usr/bin/env ruby

require 'rubygems'
require 'socket'
require 'newt'

socket = TCPServer.new(10000)

begin
  Newt::Screen.new

  b1 = Newt::Button.new(1, 5, 'Button1')
  b2 = Newt::Button.new(1, 9, 'Button2')

  b = Newt::Button.new(1, 13, 'Exit')

  f = Newt::Form.new
  f.set_timer(10000)
  f.watch_fd(socket, Newt::FD_READ)
  f.add_hotkey(?\e.ord)
  f.add(b1, b2, b)

  rv = f.run
  current = f.get_current
ensure
  Newt::Screen.finish
end

puts rv.inspect
puts 'Button1' if rv == b1
puts 'Button2' if b2 == rv
puts 'Exit' if rv == b
puts 'Exit button is current button' if b == current
puts 'Escape' if rv.reason == Newt::EXIT_HOTKEY && rv.key == ?\e.ord
puts 'Timeout' if rv.reason == Newt::EXIT_TIMER
puts 'FD Watch' if rv.reason == Newt::EXIT_FDREADY
