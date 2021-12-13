# frozen_string_literal: true

require 'minitest/autorun'
require 'test_helper'
require 'newt'

class TestEntry < Minitest::Test
  def setup
    Newt.init
    @e = Newt::Entry.new(0, 0, INITIAL_TEXT, 20)
  end

  def teardown
    Newt.finish
  end

  def test_invalid_argument_count
    assert_raises(ArgumentError) do
      Newt::Checkbox.new(0, 0)
    end

    assert_raises(ArgumentError) do
      Newt::Checkbox.new(0, 0, INITIAL_TEXT, 20, 0, nil)
    end
  end

  def test_new
    Newt::Entry.new(0, 0, INITIAL_TEXT, 20)
  end

  def test_set
    @e.set(NEW_TEXT, 0)
    assert_equal(NEW_TEXT, @e.get)
    assert_equal(0, @e.get_cursor_position)
  end

  def test_get
    assert_equal(INITIAL_TEXT, @e.get)
  end

  def test_set_filter
    rv = fork_newt_ui(method(:entry_filter_interactive)) do |tty|
      tty.write('Hello')
      tty.write("\t\r")
    end
    assert_equal(true, rv)
  end

  def test_set_filter_invalid_argument_count
    assert_raises(ArgumentError) do
      @e.set_filter()
    end

    assert_raises(ArgumentError) do
      @e.set_filter(method(:entry_filter_interactive), 5, 5)
    end
  end

  def test_set_flags
    @e.set_flags(Newt::FLAG_DISABLED)
  end

  def test_set_flags_invalid_argument_count
    assert_raises(ArgumentError) do
      @e.set_flags()
    end

    assert_raises(ArgumentError) do
      @e.set_flags(Newt::FLAG_DISABLED, Newt::FLAGS_TOGGLE, 0)
    end
  end

  def test_set_colors
    @e.set_colors(Newt::COLORSET_ENTRY, Newt::COLORSET_DISENTRY)
  end

  def test_get_cursor_position
    assert_equal(INITIAL_TEXT.length, @e.get_cursor_position)
  end

  def test_set_cursor_position
    @e.set_cursor_position(5)
    assert_equal(5, @e.get_cursor_position)
  end

  def test_set_cursor_at_end
    @e.set(LONG_TEXT, 1)
    assert_equal(LONG_TEXT.length, @e.get_cursor_position)
  end

  private

  def entry_filter_callback(_w, _d, ch, _curs)
    '*'.ord if ch != "\t".ord
  end

  def entry_filter_interactive
    e = Newt::Entry.new(1, 1, '', 10)
    b = Newt::Button.new(1, 2, 'Exit')
    e.set_filter(method(:entry_filter_callback))
    f = Newt::Form.new
    f.set_timer(1000)
    f.add(e, b)
    f.run
    e.get == '*****'
  end
end

class TestEntryUninitialized < Minitest::Test
  def setup
    Newt.init
    @e = Newt::Entry.new(0, 0, INITIAL_TEXT, 20)
    Newt.finish
  end

  def test_new
    assert_init_exception do
      Newt::Entry.new(0, 0, INITIAL_TEXT, 20)
    end
  end

  def test_set
    assert_init_exception do
      @e.set(NEW_TEXT, 0)
    end
  end

  def test_get
    assert_init_exception do
      @e.get
    end
  end

  def test_set_filter
    assert_init_exception do
      @e.set_filter(:entry_filter_callback)
    end
  end

  def test_set_flags
    assert_init_exception do
      @e.set_flags(Newt::FLAG_DISABLED)
    end
  end

  def test_set_colors
    assert_init_exception do
      @e.set_colors(Newt::COLORSET_ENTRY, Newt::COLORSET_DISENTRY)
    end
  end

  def test_get_cursor_position
    assert_init_exception do
      @e.get_cursor_position
    end
  end

  def test_set_cursor_position
    assert_init_exception do
      @e.set_cursor_position(5)
    end
  end

  private

  def entry_filter_callback
    nil
  end
end
