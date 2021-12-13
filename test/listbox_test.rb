# frozen_string_literal: true

require 'minitest/autorun'
require 'test_helper'
require 'newt'

class TestListbox < Minitest::Test
  def setup
    Newt.init
    @lb = Newt::Listbox.new(0, 0, 0)
    1.upto(5) do |i|
      @lb.append("item#{i}", i)
    end
  end

  def teardown
    Newt.finish
  end

  def test_invalid_argument_count
    assert_raises(ArgumentError) do
      Newt::Listbox.new(0, 0)
    end

    assert_raises(ArgumentError) do
      Newt::Listbox.new(0, 0, 0, 0, 0)
    end
  end

  def test_new
    Newt::Listbox.new(0, 0, 0)
  end

  def test_get_curent
    @lb.set_current(2)
    assert_equal(3, @lb.get_current)
  end

  def test_get_current_empty_list
    lb = Newt::Listbox.new(0, 0, 0)
    assert_equal(false, lb.get_current)
  end

  def test_get_current_string
    lb = Newt::Listbox.new(0, 0, 0)
    1.upto(5) do |i|
      lb.append("item#{i}", "String no. #{i}")
    end
    lb.set_current(2)
    assert_equal('String no. 3', lb.get_current)
  end

  def test_set_current
    rnd = rand(1000)
    @lb.set_data(3, rnd)
    @lb.set_current(3)
    assert_equal(rnd, @lb.get_current)
  end

  def test_set_current_by_key
    @lb.set_current_by_key(3)
    assert_equal(3, @lb.get_current)
  end

  def test_set_width
    @lb.set_width(20)
    size = @lb.get_size
    assert_equal(size[0], 20)
  end

  def test_set_data
    @lb.set_data(2, 10)
    assert_equal(['item3', 10], @lb.get(2))
  end

  def test_append
    @lb.append('item6', 6)
    assert_equal(['item6', 6], @lb.get(5))
  end

  def test_add_unusual_data
    time = Time.now
    @lb.append('item6', time)
    @lb.set_current(5)
    assert_equal(time, @lb.get_current)
  end

  def test_insert
    assert_equal(5, @lb.item_count)
    @lb.insert('inserted', 100, 3)
    assert_equal(6, @lb.item_count)
  end

  def test_get
    assert_equal(['item3', 3], @lb.get(2))
  end

  def test_set
    @lb.set(2, 'newitem3')
    assert_equal(['newitem3', 3], @lb.get(2))
  end

  def test_delete
    @lb.delete(4)
    @lb.delete(2)
    assert_equal(3, @lb.item_count)
  end

  def test_clear
    assert_equal(5, @lb.item_count)
    @lb.clear
    assert_equal(0, @lb.item_count)
  end

  def test_get_selection
    @lb.select(2, Newt::FLAGS_SET)
    @lb.select(5, Newt::FLAGS_SET)
    assert_equal([2, 5], @lb.get_selection.sort)
  end

  def test_clear_selection
    @lb.select(2, Newt::FLAGS_SET)
    @lb.select(5, Newt::FLAGS_SET)
    assert_equal([2, 5], @lb.get_selection.sort)

    @lb.clear_selection
    assert_equal([], @lb.get_selection)
  end

  def test_select
    @lb.select(2, Newt::FLAGS_SET)
    assert_equal([2], @lb.get_selection.sort)
  end

  def test_item_count
    assert_equal(5, @lb.item_count)

    rnd = rand(7..20)
    6.upto(rnd) do |i|
      @lb.append("item#{i}", nil)
    end
    assert_equal(rnd, @lb.item_count)
  end
end

class TestListboxUninitialized < Minitest::Test
  def setup
    Newt.init
    @lb = Newt::Listbox.new(0, 0, 0)
    1.upto(5) do |i|
      @lb.append("item#{i}", i)
    end
    Newt.finish
  end

  def test_new
    assert_init_exception do
      Newt::Listbox.new(0, 0, 0)
    end
  end

  def test_get_curent
    assert_init_exception do
      @lb.get_current
    end
  end

  def test_set_current
    assert_init_exception do
      @lb.set_current(3)
    end
  end

  def test_set_current_by_key
    assert_init_exception do
      @lb.set_current_by_key(3)
    end
  end

  def test_set_width
    assert_init_exception do
      @lb.set_width(20)
    end
  end

  def test_set_data
    assert_init_exception do
      @lb.set_data(2, 10)
    end
  end

  def test_append
    assert_init_exception do
      @lb.append('item6', 6)
    end
  end

  def test_insert
    assert_init_exception do
      @lb.insert('inserted', 100, 3)
    end
  end

  def test_get
    assert_init_exception do
      @lb.get(2)
    end
  end

  def test_set
    assert_init_exception do
      @lb.set(2, 'newitem3')
    end
  end

  def test_delete
    assert_init_exception do
      @lb.delete(4)
    end
  end

  def test_clear
    assert_init_exception do
      @lb.clear
    end
  end

  def test_get_selection
    assert_init_exception do
      @lb.select(2, Newt::FLAGS_SET)
    end
  end

  def test_clear_selection
    assert_init_exception do
      @lb.clear_selection
    end
  end

  def test_select
    assert_init_exception do
      @lb.select(2, Newt::FLAGS_SET)
    end
  end
end
