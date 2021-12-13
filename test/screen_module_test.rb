# frozen_string_literal: true

require 'minitest/autorun'
require 'test_helper'
require 'newt'

class TestScreenModule < Minitest::Test
  def setup
    Newt.init
  end

  def teardown
    Newt.finish
  end

  def test_cls
    Newt::Screen.cls
  end

  def test_wait_for_key
    fork_newt_ui(method(:wait_for_key_interactive)) do |tty|
      tty.write("\r")
    end
  end

  def test_clear_keybuffer
    Newt::Screen.clear_keybuffer
  end

  def test_open_window
    Newt::Screen.open_window(0, 0, 10, 10, 'Window')
  end

  def test_centered_window
    Newt::Screen.centered_window(10, 10, 'Window')
  end

  def test_pop_window
    Newt::Screen.pop_window
  end

  def test_set_colors
    Newt::Screen.set_colors(borderFg: 'yellow', borderBg: 'cyan')
  end

  def test_set_color
    Newt::Screen.set_color(Newt::COLORSET_CUSTOM(1), 'black', 'red')
  end
  
  def test_refresh
    Newt::Screen.refresh
  end

  def test_suspend
    Newt::Screen.suspend
  end

  def test_resume
    Newt::Screen.suspend
    Newt::Screen.resume
  end

  def test_suspend_callback
    rv = fork_newt_ui(method(:suspend_callback_interactive)) do |tty|
      tty.write("\x1A") # code for ^Z
      tty.write("\r")
    end
    assert_equal(true, rv)
  end

  def test_suspend_callback_invalid_argument_count
    rv = fork_newt_ui(method(:suspend_callback_invalid_arg_count)) do |tty|
      tty.write("\x1A") # code for ^Z
      tty.write("\r")
    end
    assert_equal(true, rv)
  end

  def test_help_callback
    rv = fork_newt_ui(method(:help_callback_interactive)) do |tty|
      tty.write("\eOP") # escape code for F1 key
      tty.write("\r")
    end
    assert_equal(true, rv)
  end

  def test_help_callback_invalid_argument_count
    rv = fork_newt_ui(method(:help_callback_invalid_arg_count)) do |tty|
      tty.write("\eOP") # escape code for F1 key
      tty.write("\r")
    end
    assert_equal(true, rv)
  end

  def test_push_helpline
    Newt::Screen.push_helpline('Help!')
  end

  def test_redraw_helpline
    Newt::Screen.redraw_helpline
  end

  def test_pop_helpline
    Newt::Screen.pop_helpline
  end

  def test_draw_roottext
    Newt::Screen.draw_roottext(0, 0, 'Hello!')
  end

  def test_bell
    Newt::Screen.bell
  end

  def test_cursor_off
    Newt::Screen.cursor_off
  end

  def test_cursor_on
    Newt::Screen.cursor_on
  end

  def test_size
    Newt::Screen.size
  end

  def test_win_message
    fork_newt_ui(method(:win_message_interactive)) do |tty|
      tty.write("\r")
    end
  end

  def test_win_choice
    fork_newt_ui(method(:win_choice_interactive)) do |tty|
      tty.write("\r")
    end
  end

  def test_win_menu
    fork_newt_ui(method(:win_menu_interactive)) do |tty|
      tty.write("\r")
    end
  end
  
  def test_win_entries
    fork_newt_ui(method(:win_entries_interactive)) do |tty|
      tty.write("\r\r\r\r\r")
    end
  end

  private
  
  def suspend_callback(data)
    @called = true
  end

  def suspend_callback_interactive
    @called = false
    Newt::Screen.suspend_callback(method(:suspend_callback))
    b = Newt::Button.new(1, 1, 'Exit')
    f = Newt::Form.new

    f.add(b)
    f.run

    @called == true
  end

  def suspend_callback_invalid
    @called = true
  end

  def suspend_callback_invalid_arg_count
    @called = false
    @error  = false
    Newt::Screen.suspend_callback(method(:suspend_callback_invalid))
    b = Newt::Button.new(1, 1, 'Exit')
    f = Newt::Form.new
    f.add(b)

    begin
      f.run
    rescue ArgumentError
      @error = true
    end

    @error == true
  end

  def help_callback(form, data)
    @called = true
  end

  def help_callback_interactive
    @called = false
    Newt::Screen.help_callback(method(:help_callback))
    b = Newt::Button.new(1, 1, 'Exit')
    f = Newt::Form.new

    f.add(b)
    f.run

    @called == true
  end

  def help_callback_invalid
    @called = true
  end

  def help_callback_invalid_arg_count
    @called = false
    @error  = false
    Newt::Screen.help_callback(method(:help_callback_invalid))
    b = Newt::Button.new(1, 1, 'Exit')
    f = Newt::Form.new
    f.add(b)

    begin
      f.run
    rescue ArgumentError
      @error = true
    end

    @error == true
  end

  def wait_for_key_interactive
    Newt::Screen.wait_for_key
  end

  def win_message_interactive
    Newt::Screen.win_message('Message', 'Ok', 'Message')
  end

  def win_choice_interactive
    Newt::Screen.win_choice('Choice', 'Ok', 'Cancel', 'Choice')
  end

  def win_menu_interactive
    Newt::Screen.win_menu('Menu', 'Text', 50, 5, 5, 3,
                          %w[One Two Three], 'OK')
  end

  def win_entries_interactive
    entries = ['Entry1', 'Entry2', 'Entry3', 'Entry4']

    Newt::Screen.win_entries('Entries', 'Message', 50, 5, 5, 20,
                             entries, 'Ok', 'Cancel')
  end
end

class TestScreenModuleUninitialized < Minitest::Test
  def test_cls
    assert_init_exception do
      Newt::Screen.cls
    end
  end

  def test_wait_for_key
    assert_init_exception do
      Newt::Screen.wait_for_key
    end
  end

  def test_clear_keybuffer
    assert_init_exception do
      Newt::Screen.clear_keybuffer
    end
  end

  def test_open_window
    assert_init_exception do
      Newt::Screen.open_window(0, 0, 10, 10, 'Window')
    end
  end

  def test_centered_window
    assert_init_exception do
      Newt::Screen.centered_window(10, 10, 'Window')
    end
  end

  def test_pop_window
    assert_init_exception do
      Newt::Screen.pop_window
    end
  end

  def test_set_colors
    assert_init_exception do
      Newt::Screen.set_colors(borderFg: 'yellow', borderBg: 'cyan')
    end
  end

  def test_set_color
    assert_init_exception do
      Newt::Screen.set_color(Newt::COLORSET_CUSTOM(1), 'black', 'red')
    end
  end
  
  def test_refresh
    assert_init_exception do
      Newt::Screen.refresh
    end
  end

  def test_suspend
    assert_init_exception do
      Newt::Screen.suspend
    end
  end

  def test_resume
    assert_init_exception do
      Newt::Screen.resume
    end
  end

  def test_suspend_callback
    assert_init_exception do
      Newt::Screen.suspend_callback(method(:empty_callback))
    end
  end

  def test_help_callback
    assert_init_exception do
      Newt::Screen.help_callback(method(:empty_callback))
    end
  end

  def test_push_helpline
    assert_init_exception do
      Newt::Screen.push_helpline('Help!')
    end
  end

  def test_redraw_helpline
    assert_init_exception do
      Newt::Screen.redraw_helpline
    end
  end

  def test_pop_helpline
    assert_init_exception do
      Newt::Screen.pop_helpline
    end
  end

  def test_draw_roottext
    assert_init_exception do
      Newt::Screen.draw_roottext(0, 0, 'Hello!')
    end
  end

  def test_bell
    assert_init_exception do
      Newt::Screen.bell
    end
  end

  def test_cursor_off
    assert_init_exception do
      Newt::Screen.cursor_off
    end
  end

  def test_cursor_on
    assert_init_exception do
      Newt::Screen.cursor_on
    end
  end

  def test_size
    assert_init_exception do
      Newt::Screen.size
    end
  end

  def test_win_message
    assert_init_exception do
      Newt::Screen.win_message('Message', 'Ok', 'Message')
    end
  end

  def test_win_choice
    assert_init_exception do
      Newt::Screen.win_choice('Choice', 'Ok', 'Cancel', 'Choice')
    end
  end

  def test_win_menu
    assert_init_exception do
      Newt::Screen.win_menu('Menu', 'Text', 50, 5, 5, 3,
                            %w[One Two Three], 'OK')
    end
  end
  
  def test_win_entries
    entries = ['Entry1', 'Entry2', 'Entry3', 'Entry4']

    assert_init_exception do
      Newt::Screen.win_entries('Entries', 'Message', 50, 5, 5, 20,
                               entries, 'Ok', 'Cancel')
    end
  end

  private

  def empty_callback
  end
end
