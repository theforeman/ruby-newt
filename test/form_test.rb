# frozen_string_literal: true

require 'minitest/autorun'
require 'weakref'
require 'test_helper'
require 'newt'

class TestForm < Minitest::Test
  def setup
    Newt.init
    @f = Newt::Form.new
  end

  def teardown
    Newt.finish
  end

  def test_invalid_argument_count
    assert_raises(ArgumentError) do
      Newt::Form.new(1, 1, 1, 1)
    end
  end

  def test_new
    Newt::Form.new
  end

  def test_help_tag_is_retained
    help_tag = Object.new
    weak_tag = WeakRef.new(help_tag)
    form = Newt::Form.new(nil, help_tag)
    help_tag = nil

    GC.start
    assert_equal(true, weak_tag.weakref_alive?)
    assert_kind_of(Newt::Form, form)
  end

  def test_set_background
    @f.set_background(1)
  end

  def test_add
    b = Newt::Button.new(1, 1, 'Button')
    @f.add(b)
  end

  def test_set_size
    @f.set_size
  end

  def test_get_current
    b1 = Newt::Button.new(1, 1, 'Button1')
    b2 = Newt::Button.new(1, 2, 'Button2')
    @f.add(b1, b2)

    c = @f.get_current
    assert_equal(b1, c)
  end

  def test_set_current
    b1 = Newt::Button.new(1, 1, 'Button1')
    b2 = Newt::Button.new(1, 2, 'Button2')
    @f.add(b1, b2)
    @f.set_current(b2)

    c = @f.get_current
    assert_equal(b2, c)
  end

  def test_set_height
    @f.set_height(5)
  end

  def test_set_width
    @f.set_width(5)
  end

  def test_run
    rv = fork_newt_ui(method(:form_run_interactive)) do |tty|
      tty.write("\r")
    end
    assert_equal(true, rv)
  end

  def test_draw
    @f.draw
  end

  def test_add_hotkey
    rv = fork_newt_ui(method(:form_hotkey_interactive)) do |tty|
      tty.write("\e[21~") # Escape code for F10 key
    end
    assert_equal(true, rv)
  end

  def test_set_timer
    time = Time.now
    rv = fork_newt_ui(method(:form_timer_interactive))
    assert_equal(true, rv)
    assert_in_delta(1, Time.now - time, 0.01)
  end

  def test_watch_fd
    rv = fork_newt_ui(method(:form_watch_fd_interactive))
    assert_equal(true, rv)
  end

  def test_watch_fd_with_integer
    @f.watch_fd(0, Newt::FD_READ)
  end

  def test_component_type
    rv = fork_newt_ui(method(:form_component_interactive)) do |tty|
      tty.write("\r")
    end
    assert_equal(true, rv)
  end

  private

  def form_run_interactive
    b = Newt::Button.new(1, 1, 'Button')
    f = Newt::Form.new
    f.add(b)
    rv = f.run
    rv.reason == Newt::EXIT_COMPONENT
  end

  def form_hotkey_interactive
    b = Newt::Button.new(1, 1, 'Button')
    f = Newt::Form.new
    f.add_hotkey(Newt::KEY_F10)
    f.add(b)
    rv = f.run
    rv.reason == Newt::EXIT_HOTKEY && rv.key == Newt::KEY_F10 &&
      rv.component.nil? && rv.inspect.include?('key=')
  end

  def form_timer_interactive
    b = Newt::Button.new(1, 1, 'Button')
    f = Newt::Form.new
    f.set_timer(1000)
    f.add(b)
    rv = f.run
    rv.reason == Newt::EXIT_TIMER && rv.component.nil? && rv.inspect.include?('reason=')
  end

  def form_watch_fd_interactive
    b = Newt::Button.new(1, 1, 'Button')
    f = Newt::Form.new
    f.add(b)
    file = File.open('/dev/null', 'r')
    f.watch_fd(file, Newt::FD_READ)
    rv = f.run
    rv.reason == Newt::EXIT_FDREADY && rv.watch == file.fileno &&
      rv.component.nil? && rv.key.nil? && rv.inspect.include?('watch=')
  end

  def form_component_interactive
    b = Newt::Button.new(1, 1, 'Button')
    f = Newt::Form.new
    f.add(b)
    rv = f.run
    other = Newt::Button.new(1, 2, 'Other')
    rv.component.class == Newt::Button && rv.component == b && rv == b && rv != other &&
      rv.watch.nil? && rv.key.nil? && rv.inspect.include?('component=')
  end
end

class TestFormUninitialized < Minitest::Test
  def setup
    Newt.init
    @f = Newt::Form.new
    @b1 = Newt::Button.new(1, 1, 'Button1')
    @b2 = Newt::Button.new(1, 2, 'Button2')
    @b3 = Newt::Button.new(1, 3, 'Button3')

    @f.add(@b1, @b2)
    Newt.finish
  end

  def test_new
    assert_init_exception do
      Newt::Form.new
    end
  end

  def test_set_background
    assert_init_exception do
      @f.set_background(1)
    end
  end

  def test_add
    assert_init_exception do
      @f.add(@b3)
    end
  end

  def test_set_size
    assert_init_exception do
      @f.set_size
    end
  end

  def test_get_current
    assert_init_exception do
      @f.get_current
    end
  end

  def test_set_current
    assert_init_exception do
      @f.set_current(@b2)
    end
  end

  def test_set_height
    assert_init_exception do
      @f.set_height(5)
    end
  end

  def test_set_width
    assert_init_exception do
      @f.set_width(5)
    end
  end

  def test_run
    assert_init_exception do
      @f.run
    end
  end

  def test_draw
    assert_init_exception do
      @f.draw
    end
  end

  def test_add_hotkey
    assert_init_exception do
      @f.add_hotkey(Newt::KEY_F1)
    end
  end

  def test_set_timer
    assert_init_exception do
      @f.set_timer(100)
    end
  end

  def test_watch_fd
    assert_init_exception do
      @f.watch_fd(0, Newt::FD_READ)
    end
  end
end
