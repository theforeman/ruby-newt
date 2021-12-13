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
  end

  def test_inspect
    @b.inspect
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
