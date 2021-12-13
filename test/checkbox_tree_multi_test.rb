# frozen_string_literal: true

require 'minitest/autorun'
require 'test_helper'
require 'newt'

class TestCheckboxTreeMulti < Minitest::Test
  def setup
    Newt.init
    @ct = Newt::CheckboxTreeMulti.new(1, 1, 3, ' ab', 0)
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
      Newt::CheckboxTreeMulti.new(0, 0)
    end

    assert_raises(ArgumentError) do
      Newt::CheckboxTreeMulti.new(0, 0, 0, 0, 0, 0)
    end
  end

  def test_new
    Newt::CheckboxTreeMulti.new(1, 1, 3, ' ab', 0)
  end

  def test_add
    @ct.add('Checkbox6', 6, 0, Newt::ARG_APPEND)
  end

  def test_add_unusual_data
    time = Time.now
    @ct.add('Checkbox6', time, 0, Newt::ARG_APPEND)
    @ct.set_current(time)
    assert_equal(time, @ct.get_current)
  end

  def test_get_selection
    @ct.set(1, 'a')
    @ct.set(2, 'b')
    @ct.set(4, 'a')
    assert_equal([1, 4], @ct.get_selection('a'))
    assert_equal([2],    @ct.get_selection('b'))
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
    ct = Newt::CheckboxTree.new(1, 1, 3, 0)
    assert_nil(ct.get(1))
  end

  def test_set
    @ct.set(1, 'b')
    assert_equal('b', @ct.get(1))
  end

  def test_set_long_string
    @ct.set(1, 'bextra text')
    assert_equal('b', @ct.get(1))
  end

  def test_new_no_sequence_arg
    ct = Newt::CheckboxTreeMulti.new(1, 1, 1)
    ct.add('Checkbox1', 1, 0, Newt::ARG_APPEND)
    ct.set(1, '*')
    assert_equal('*', ct.get(1))
  end

  def test_new_nil_sequence
    ct = Newt::CheckboxTreeMulti.new(1, 1, 1, nil, 0)
    ct.add('Checkbox1', 1, 0, Newt::ARG_APPEND)
    ct.set(1, '*')
    assert_equal('*', ct.get(1))
  end

  def test_new_empty_sequence
    ct = Newt::CheckboxTreeMulti.new(1, 1, 1, '', 0)
    ct.add('Checkbox1', 1, 0, Newt::ARG_APPEND)
    ct.set(1, '*')
    assert_equal('*', ct.get(1))
  end
end

class TestCheckboxTreeMultiUninitialized < Minitest::Test
  def setup
    Newt.init
    @ct = Newt::CheckboxTreeMulti.new(1, 1, 3, ' ab', 0)
    @ct.add('Checkbox1', 1, 0, Newt::ARG_APPEND)
    @ct.add('Checkbox2', 2, 0, Newt::ARG_APPEND)
    @ct.add('Checkbox3', 3, 0, Newt::ARG_APPEND)
    @ct.add('Checkbox4', 4, 0, 2, Newt::ARG_APPEND)
    @ct.add('Checkbox5', 5, 0, 2, Newt::ARG_APPEND)
    Newt.finish
  end

  def test_new
    assert_init_exception do
      Newt::CheckboxTreeMulti.new(1, 1, 3, ' ab', 0)
    end
  end

  def test_add
    assert_init_exception do
      @ct.add('Checkbox6', 6, 0, Newt::ARG_APPEND)
    end
  end

  def test_get_selection
    assert_init_exception do
      @ct.get_selection('a')
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

  def test_entry
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
      @ct.set(1, 'b')
    end
  end
end
