# frozen_string_literal: true

require 'minitest/autorun'
require 'test_helper'
require 'newt'

class TestGrid < Minitest::Test
  def setup
    Newt.init
  end

  def teardown
    Newt.finish
  end

  def test_invalid_columns
    assert_raises(RuntimeError) do
      Newt::Grid.new(0, 2)
    end
  end

  def test_invalid_rows
    assert_raises(RuntimeError) do
      Newt::Grid.new(2, 0)
    end
  end

  def test_invalid_field_position
    grid = Newt::Grid.new(2, 1)
    b = Newt::Button.new(-1, -1, 'Button')
    assert_raises(RuntimeError) do
      grid.set_field(0, 1, Newt::GRID_COMPONENT, b, 0, 0, 0, 0, 0, 0)
    end
  end

  def test_new
    Newt::Grid.new(2, 2)
  end

  def test_set_field
    b1 = Newt::Button.new(-1, -1, 'Button1')
    b2 = Newt::Button.new(-1, -1, 'Button2')

    grid = Newt::Grid.new(2, 1)
    grid.set_field(0, 0, Newt::GRID_COMPONENT, b1, 0, 0, 0, 0, 0, 0)
    grid.set_field(1, 0, Newt::GRID_COMPONENT, b2, 0, 0, 0, 0, 0, 0)
  end

  def test_wrapped_window
    b1 = Newt::Button.new(-1, -1, 'Button1')
    b2 = Newt::Button.new(-1, -1, 'Button2')

    grid = Newt::Grid.new(2, 1)
    grid.set_field(0, 0, Newt::GRID_COMPONENT, b1, 0, 0, 0, 0, 0, 0)
    grid.set_field(1, 0, Newt::GRID_COMPONENT, b2, 0, 0, 0, 0, 0, 0)
    grid.wrapped_window('Window')
  end

  def test_wrapped_window_invalid_argument_count
    grid = Newt::Grid.new(2, 1)
    assert_raises(ArgumentError) do
      grid.wrapped_window('Window', 1)
    end
    assert_raises(ArgumentError) do
      grid.wrapped_window('Window', 1, 2, 3)
    end
  end

  def test_get_size
    b1 = Newt::Button.new(-1, -1, 'Button1')
    b2 = Newt::Button.new(-1, -1, 'Button2')

    grid = Newt::Grid.new(2, 1)
    grid.set_field(0, 0, Newt::GRID_COMPONENT, b1, 0, 0, 0, 0, 0, 0)
    grid.set_field(1, 0, Newt::GRID_COMPONENT, b2, 0, 0, 0, 0, 0, 0)
    assert_equal([24, 4], grid.get_size)
  end
end

class TestGridUninitialized < Minitest::Test
  def setup
    Newt.init
    b1 = Newt::Button.new(-1, -1, 'Button1')
    b2 = Newt::Button.new(-1, -1, 'Button2')

    @grid = Newt::Grid.new(3, 1)
    @grid.set_field(0, 0, Newt::GRID_COMPONENT, b1, 0, 0, 0, 0, 0, 0)
    @grid.set_field(1, 0, Newt::GRID_COMPONENT, b2, 0, 0, 0, 0, 0, 0)
    Newt.finish
  end

  def test_new
    assert_init_exception do
      Newt::Grid.new(2, 2)
    end
  end

  def test_set_field
    assert_init_exception do
      b = Newt::Button.new(-1, -1, 'Button3')
      @grid.set_field(2, 0, Newt::GRID_COMPONENT, b, 0, 0, 0, 0, 0, 0)
    end
  end

  def test_wrapped_window
    assert_init_exception do
      @grid.wrapped_window('Window')
    end
  end

  def test_get_size
    assert_init_exception do
      assert_equal([24, 4], @grid.get_size)
    end
  end
end
