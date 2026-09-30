# frozen_string_literal: true

require 'minitest/autorun'
require 'test_helper'
require 'newt'

class TestWidget < Minitest::Test
  def setup
    Newt.init
    @b = Newt::Button.new(1, 1, 'Exit')
  end

  def teardown
    Newt.finish
  end

  def test_takes_focus
    @b.takes_focus(1)
  end

  def test_get_position
    x, y = @b.get_position
    assert_equal(x, 1)
    assert_equal(y, 1)
  end

  def test_get_size
    w, h = @b.get_size
    assert_equal(9, w)
    assert_equal(4, h)
  end

  def test_equal
    assert(@b == @b)
    refute(@b == Newt::Button.new(1, 1, 'Other'))
  end

  def test_inspect
    @b.inspect
  end

  def test_callback_with_proc
    rv = fork_newt_ui(method(:widget_callback_with_proc_interactive)) do |tty|
      tty.write("\r")
    end
    assert_equal(true, rv)
  end

  def test_callback_with_method
    rv = fork_newt_ui(method(:widget_callback_with_method_interactive)) do |tty|
      tty.write("\r")
    end
    assert_equal(true, rv)
  end

  def test_callback_invalid_argument_count
    assert_raises(ArgumentError) { @b.callback }
    assert_raises(ArgumentError) { @b.callback(proc {}, :data, :extra) }
  end

  private

  def widget_callback_with_proc_interactive
    button = Newt::Button.new(1, 1, 'Callback')
    form = Newt::Form.new
    register_widget_proc_callback(form)
    form.add(button)
    GC.start
    form.run
    @callback_result == [Newt::Form, :payload]
  end

  def widget_callback_with_method_interactive
    button = Newt::Button.new(1, 1, 'Callback')
    form = Newt::Form.new
    form.callback(:record_widget_callback, :payload)
    form.add(button)
    form.run
    @callback_result == [Newt::Form, :payload]
  end

  def register_widget_proc_callback(button)
    callback = proc { |widget, data| @callback_result = [widget.class, data] }
    button.callback(callback, :payload)
  end

  def record_widget_callback(widget, data)
    @callback_result = [widget.class, data]
  end
end

class TestWidgetUninitialized < Minitest::Test
  def setup
    Newt.init
    @b = Newt::Button.new(1, 1, 'Exit')
    Newt.finish
  end

  def test_takes_focus
    assert_init_exception do
      @b.takes_focus(1)
    end
  end

  def test_get_position
    assert_init_exception do
      @b.get_position
    end
  end

  def test_get_size
    assert_init_exception do
      @b.get_size
    end
  end
end
