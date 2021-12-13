# frozen_string_literal: true

require 'minitest/autorun'
require 'test_helper'
require 'newt'

class TestCheckboxTree < Minitest::Test
  def setup
    Newt.init
    @ct = Newt::CheckboxTree.new(1, 1, 3)
    @ct.add('Checkbox1', 1, 0, Newt::ARG_APPEND)
    @ct.add('Checkbox2', 2, 0, Newt::ARG_APPEND)
    @ct.add('Checkbox3', 3, 0, Newt::ARG_APPEND)
    @ct.add('Checkbox4', 4, 0, 2, Newt::ARG_APPEND)
    @ct.add('Checkbox5', 5, 0, 2, Newt::ARG_APPEND)
  end

  def teardown
    Newt.finish
  end

  def test_invalid_argument_count
    assert_raises(ArgumentError) do
      Newt::CheckboxTree.new(0, 0)
    end

    assert_raises(ArgumentError) do
      Newt::CheckboxTree.new(0, 0, 0, 0, 0)
    end
  end

  def test_new
    Newt::CheckboxTree.new(1, 1, 3)
  end

  def test_add
    @ct.add('Checkbox6', 6, 0, 2, Newt::ARG_APPEND)
  end

  def test_add_invalid_argument_count
    assert_raises(ArgumentError) do
      @ct.add('Checkbox6')
    end
  end

  def test_get_selection
    @ct.set(1, '*')
    @ct.set(2, '*')
    @ct.set(4, '*')
    assert_equal([1, 2, 4], @ct.get_selection)
  end

  def test_get_current
    assert_equal(1, @ct.get_current)
  end

  def test_set_current
    @ct.set_current(3)
    assert_equal(3, @ct.get_current)
  end

  def test_find
    assert_equal([2, 1], @ct.find(5))
  end

  def test_find_invalid
    assert_nil(@ct.find(100))
  end

  def test_set_entry
    @ct.set_entry(1, 'New Name')
  end

  def test_set_width
    @ct.set_width(20)
    size = @ct.get_size
    assert_equal(size[0], 20)
  end

  def test_get
    assert_equal(' ', @ct.get(1))
  end

  def test_get_invalid
    ct = Newt::CheckboxTree.new(1, 1, 3)
    assert_nil(ct.get(1))
  end

  def test_set
    @ct.set(1, '*')
    assert_equal('*', @ct.get(1))
  end

  def test_set_long_string
    @ct.set(1, '*extra text')
    assert_equal('*', @ct.get(1))
  end

  def test_add_unusual_data
    time = Time.now
    @ct.add('Checkbox6', time, 0, Newt::ARG_APPEND)
    @ct.set_current(time)
    assert_equal(time, @ct.get_current)
  end
end

class TestCheckboxTreeUninitialized < Minitest::Test
  def setup
    Newt.init
    @ct = Newt::CheckboxTree.new(1, 1, 3)
    @ct.add('Checkbox1', 1, 0, Newt::ARG_APPEND)
    @ct.add('Checkbox2', 2, 0, Newt::ARG_APPEND)
    @ct.add('Checkbox3', 3, 0, Newt::ARG_APPEND)
    @ct.add('Checkbox4', 4, 0, 2, Newt::ARG_APPEND)
    @ct.add('Checkbox5', 5, 0, 2, Newt::ARG_APPEND)
    Newt.finish
  end

  def test_new
    assert_init_exception do
      Newt::CheckboxTree.new(1, 1, 3)
    end
  end

  def test_add
    assert_init_exception do
      @ct.add('Checkbox6', 6, 0, 2, Newt::ARG_APPEND)
    end
  end

  def test_get_selection
    assert_init_exception do
      @ct.get_selection
    end
  end

  def test_get_current
    assert_init_exception do
      @ct.get_current
    end
  end

  def test_set_current
    assert_init_exception do
      @ct.set_current(3)
    end
  end

  def test_find
    assert_init_exception do
      @ct.find(5)
    end
  end

  def test_set_entry
    assert_init_exception do
      @ct.set_entry(1, 'New Name')
    end
  end

  def test_set_width
    assert_init_exception do
      @ct.set_width(20)
    end
  end

  def test_get
    assert_init_exception do
      @ct.get(1)
    end
  end

  def test_set
    assert_init_exception do
      @ct.set(1, '*')
    end
  end
end
