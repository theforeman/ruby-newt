# frozen_string_literal: true

require 'minitest/autorun'
require 'test_helper'
require 'newt'

class TestRadiobutton < Minitest::Test
  def setup
    Newt.init
    @rb1 = Newt::RadioButton.new(1, 1, 'Button1', 1)
    @rb2 = Newt::RadioButton.new(1, 2, 'Button2', 0, @rb1)
  end

  def teardown
    Newt.finish
  end

  def test_invalid_argument_count
    assert_raises(ArgumentError) do
      Newt::RadioButton.new(1, 1)
    end

    assert_raises(ArgumentError) do
      Newt::RadioButton.new(1, 1, 'Text', 0, @rb1, nil)
    end
  end

  def test_new
    Newt::RadioButton.new(1, 1, 'Text', 1)
  end

  def test_get_current
    assert_equal(@rb1, @rb2.get_current)
  end

  def test_set_current
    @rb2.set_current
    assert_equal(@rb2, @rb1.get_current)
  end
end

class TestRadiobuttonUninitialized < Minitest::Test
  def setup
    Newt.init
    @rb1 = Newt::RadioButton.new(1, 1, 'Button1', 1)
    @rb2 = Newt::RadioButton.new(1, 2, 'Button2', 0, @rb1)
    Newt.finish
  end

  def test_new
    assert_init_exception do
      Newt::RadioButton.new(1, 1, 'Text', 1)
    end
  end

  def test_get_current
    assert_init_exception do
      assert_equal(@rb1, @rb2.get_current)
    end
  end

  def test_set_current
    assert_init_exception do
      @rb2.set_current
    end
  end
end
