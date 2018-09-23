#!/usr/bin/env ruby

require 'rubygems'
require 'newt'

def disable_callback(cs, en)
  if cs.get == ' '
    en.set_flags(Newt::FLAG_DISABLED, Newt::FLAGS_RESET)
  else
    en.set_flags(Newt::FLAG_DISABLED, Newt::FLAGS_SET)
  end
  Newt::Screen.refresh
end

Newt::Screen.new

Newt::Screen.draw_roottext(0, 0, 'Newt test program')
Newt::Screen.push_helpline('')
Newt::Screen.draw_roottext(-50, 0, 'More root text')

Newt::Screen.open_window(2, 2, 30, 10, 'first window')
Newt::Screen.open_window(10, 5, 65, 16, 'window 2')

f = Newt::Form.new
chklist = Newt::Form.new

b1 = Newt::Button.new(3, 1, 'Exit')
b2 = Newt::Button.new(18, 1, 'Update')
r1 = Newt::RadioButton.new(20, 10, 'Choice 1', 0, nil)
r2 = Newt::RadioButton.new(20, 11, 'Chc 2', 1, r1)
r3 = Newt::RadioButton.new(20, 12, 'Choice 3', 0, r2)
rsf = Newt::Form.new
rsf.add(r1, r2, r3)
rsf.set_background(Newt::COLORSET_CHECKBOX)

Newt::Screen.refresh

cs = []
(0...10).each do |i|
  buf = format('Check %d', i)
  cs[i] = Newt::Checkbox.new(3, 10 + i, buf)
  chklist.add(cs[i])
end

l1 = Newt::Label.new(3, 6, 'Scale:')
l2 = Newt::Label.new(3, 7, 'Scrolls:')
l3 = Newt::Label.new(3, 8, 'Hidden:')
e1 = Newt::Entry.new(12, 6, '', 20, 0)
e2 = Newt::Entry.new(12, 7, 'Default', 20, Newt::FLAG_SCROLL)
e3 = Newt::Entry.new(12, 8, '', 20, Newt::FLAG_HIDDEN)

cs[0].callback( proc { disableCallback(cs[0], e1) } )
scale = Newt::Scale.new(3, 14, 32, 100)

chklist.set_height(3)

f.add(b1, b2, l1, l2, l3, e1, e2, e3, chklist)
f.add(rsf, scale)

lb = Newt::Listbox.new(45, 1, 6, Newt::FLAG_MULTIPLE | Newt::FLAG_BORDER |
                                 Newt::FLAG_SCROLL)
lb.append('First', 1)
lb.append('Second', 2)
lb.append('Third', 3)
lb.append('Fourth', 4)
lb.append('Sixth', 6)
lb.append('Seventh', 7)
lb.append('Eighth', 8)
lb.append('Ninth', 9)
lb.append('Tenth', 10)

lb.insert('Fifth', 5, 4)
lb.insert('Eleventh', 11, 10)
lb.delete(11)

t = Newt::Textbox.new(45, 10, 17, 5, Newt::FLAG_WRAP)
t.set_text("This is some text does it look okay?\nThis should be alone.\nThis shouldn't be printed")

f.add(lb, t)

Newt::Screen.refresh

loop do
  answer = f.run
  if answer == b2
    scale.set(e1.get.to_i)
    Newt::Screen.refresh
    answer = nil
  end
  break unless answer.nil?
end

Newt::Screen.pop_window
Newt::Screen.pop_window

Newt::Screen.finish

printf "got string 1: %s\n", e1.get
printf "got string 2: %s\n", e2.get
printf "got string 3: %s\n", e3.get

selected_list = lb.get_selection
if selected_list.count > 0
  print "\nSelected listbox items:\n"
  selected_list.each do |item|
    puts item
  end
end
