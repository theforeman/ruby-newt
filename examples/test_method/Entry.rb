#!/usr/bin/env ruby
# rubocop:disable Style/GlobalVars

require 'rubygems'
require 'newt'

$widget = nil
$data = nil
$chars = []
$cursor_positions = []

def global_callback(widget, data, char, cursor_pos)
  $widget = widget
  $data = data
  $chars.push(char)
  $cursor_positions.push(cursor_pos)
  char
end

begin
  ENTRY_NORMAL   = Newt::COLORSET_CUSTOM 1
  ENTRY_DISABLED = Newt::COLORSET_CUSTOM 2

  Newt::Screen.new
  Newt::Screen.set_color(ENTRY_NORMAL,   'black', 'red')
  Newt::Screen.set_color(ENTRY_DISABLED, 'black', 'magenta')
  Newt::Screen.centered_window(20, 10, 'Entry')


  e1 = Newt::Entry.new(1, 1, 'Entry1', 10, 0)
  e2 = Newt::Entry.new(1, 2, '', 10)
  e3 = Newt::Entry.new(1, 3, 'disabled', 10, Newt::FLAG_DISABLED)
  b = Newt::Button.new(6, 5, 'Exit')

  e1.set_colors(ENTRY_NORMAL, ENTRY_DISABLED)
  e2.set_filter(proc { |w, d, ch, curs|
    $widget = w
    $data = d
    $chars.push(ch)
    $cursor_positions.push(curs)
    ch
  }, 'Hello World!')
  e2.set('new text', 0)

  e3.set_flags(Newt::FLAG_DISABLED, Newt::FLAGS_TOGGLE)
  e3.set_filter(:global_callback, 'Hello World!')

  f = Newt::Form.new
  f.add(e1, e2, e3, b)

  f.run
ensure
  Newt::Screen.finish
end

p e1.get, e2.get, e3.get
puts
puts "$widget = #{$widget}"
puts "$data = #{$data}"
puts "$chars = #{$chars}"
puts "$cursor_positions = #{$cursor_positions}"
# rubocop:enable Style/GlobalVars
