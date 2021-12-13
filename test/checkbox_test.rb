# frozen_string_literal: true

require 'minitest/autorun'
require 'test_helper'
require 'newt'

class TestCheckbox < Minitest::Test
  def setup
    Newt.init
    @cb = Newt::Checkbox.new(0, 0, 'Checkbox')
  end

  def teardown
    Newt.finish
  end

  def test_invalid_argument_count
    assert_raises(ArgumentError) do
      Newt::Checkbox.new(0, 0)
    end

    assert_raises(ArgumentError) do
      Newt::Checkbox.new(0, 0, 'Checkbox', '*', ' *', nil)
    end
  end

  def test_new
    Newt::Checkbox.new(0, 0, 'Checkbox')
  end

  def test_get_value
    assert_equal(' ', @cb.get)
  end

  def test_get_default_value
    cb = Newt::Checkbox.new(0, 0, 'Checkbox', 'X')
    assert_equal('X', cb.get)
  end

  def test_get_with_sequence
    cb = Newt::Checkbox.new(0, 0, 'Checkbox', nil, 'AB')
    assert_equal('A', cb.get)
  end

  def test_set_value
    @cb.set('*')
    assert_equal('*', @cb.get)
  end

  def test_set_flags
    @cb.set_flags(Newt::FLAG_DISABLED)
  end

  def test_set_flags_invalid_argument_count
    assert_raises(ArgumentError) do
      @cb.set_flags()
    end

    assert_raises(ArgumentError) do
      @cb.set_flags(Newt::FLAG_DISABLED, Newt::FLAGS_TOGGLE, 0)
    end
  end
end

class TestCheckboxUninitialized < Minitest::Test
  def setup
    Newt.init
    @cb = Newt::Checkbox.new(0, 0, 'Checkbox')
    Newt.finish
  end

  def test_new
    assert_init_exception do
      Newt::Checkbox.new(0, 0, 'Checkbox')
    end
  end

  def test_get_value
    assert_init_exception do
      @cb.get
    end
  end

  def test_set_value
    assert_init_exception do
      @cb.set('*')
    end
  end

  def test_set_flags
    assert_init_exception do
      @cb.set_flags(Newt::FLAG_DISABLED)
    end
  end
end
