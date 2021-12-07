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

Newt::Screen.draw_roottext(0, 0, 'Newt ¥Æ¥¹¥È¥×¥í¥°¥é¥à')
Newt::Screen.push_helpline('')
Newt::Screen.draw_roottext(-50, 0, '¥ë¡¼¥È¥Æ¥­¥¹¥È')

Newt::Screen.open_window(2, 2, 30, 10, '£±ÈÖÌÜ¤Î¥¦¥£¥ó¥É¥¦')
Newt::Screen.open_window(10, 5, 65, 16, '¥¦¥£¥ó¥É¥¦£²')

f = Newt::Form.new
chklist = Newt::Form.new

b1 = Newt::Button.new(3, 1, '½ªÎ»')
b2 = Newt::Button.new(18, 1, '¹¹¿·')
r1 = Newt::RadioButton.new(20, 10, 'ÁªÂò»è£±', 0, nil)
r2 = Newt::RadioButton.new(20, 11, 'ÁªÂò»è£²', 1, r1)
r3 = Newt::RadioButton.new(20, 12, 'ÁªÂò»è£³', 0, r2)
rsf = Newt::Form.new
rsf.add(r1, r2, r3)
rsf.set_background(Newt::COLORSET_CHECKBOX)

Newt::Screen.refresh

cs = []
(0...10).each do |i|
  buf = format('¥Á¥§¥Ã¥¯ %d', i)
  cs[i] = Newt::Checkbox.new(3, 10 + i, buf, ' ', nil)
  chklist.add(cs[i])
end

l1 = Newt::Label.new(3, 6, '¥¹¥±¡¼¥ë:')
l2 = Newt::Label.new(3, 7, '¥¹¥¯¥í¡¼¥ë:')
l3 = Newt::Label.new(3, 8, '¥Ò¥É¥¥¥ó:')
e1 = Newt::Entry.new(12, 6, '', 20, 0)
e2 = Newt::Entry.new(12, 7, 'É¸½à', 20, Newt::FLAG_SCROLL)
e3 = Newt::Entry.new(12, 8, '', 20, Newt::FLAG_HIDDEN)

cs[0].callback( proc { disable_callback(cs[0], e1) } )
scale = Newt::Scale.new(3, 14, 32, 100)

chklist.set_height(3)

f.add(b1, b2, l1, l2, l3, e1, e2, e3, chklist)
f.add(rsf, scale)

lb = Newt::Listbox.new(45, 1, 6, Newt::FLAG_MULTIPLE | Newt::FLAG_BORDER |
                                 Newt::FLAG_SCROLL)
lb.append('£±ÈÖÌÜ', 1)
lb.append('£²ÈÖÌÜ', 2)
lb.append('£³ÈÖÌÜ', 3)
lb.append('£´ÈÖÌÜ', 4)
lb.append('£¶ÈÖÌÜ', 6)
lb.append('£·ÈÖÌÜ', 7)
lb.append('£¸ÈÖÌÜ', 8)
lb.append('£¹ÈÖÌÜ', 9)
lb.append('£±£°ÈÖÌÜ', 10)

lb.insert('£µÈÖÌÜ', 5, 4)
lb.insert('£±£±ÈÖÌÜ', 11, 10)
lb.delete(11)

t = Newt::Textbox.new(45, 10, 17, 5, Newt::FLAG_WRAP)
t.set_text('¤³¤ì¤Ï¥Æ¥­¥¹¥È¤Î¥µ¥ó¥×¥ë¤Ç¤¹¡£\nÀµ¾ï¤ËÉ½¼¨¤µ¤ì¤Æ¤¤¤Þ¤¹¤«¡©\n¤³¤ì¤ÏÃ±ÆÈ¹Ô¤Ç¤¹¡£\n¤³¤ì¤ÏÉ½¼¨¤µ¤ì¤Æ¤Ï¤¤¤±¤Þ¤»¤ó')

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

e1 = e1.get
e2 = e2.get
e3 = e3.get
selected_list = lb.get_selection

Newt::Screen.finish

printf "got string 1: %s\n", e1
printf "got string 2: %s\n", e2
printf "got string 3: %s\n", e3

if selected_list.count > 0
  print "\nSelected listbox items:\n"
  selected_list.each do |item|
    puts item
  end
end
