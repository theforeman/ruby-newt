require 'minitest/autorun'
require 'newt'

class TestListbox < Minitest::Test
  def setup
    @lb = Newt::Listbox.new(0, 0, 0)
    1.upto(5) do |i|
      @lb.append("item#{i}", i)
    end
  end

  def test_invalid_argument_count
    assert_raises(ArgumentError) do
      Newt::Listbox.new(0, 0)
    end

    assert_raises(ArgumentError) do
      Newt::Listbox.new(0, 0, 0, 0, 0)
    end
  end

  def test_item_count
    assert_equal(5, @lb.item_count)

    rnd = rand(7..20)
    6.upto(rnd) do |i|
      @lb.append("item#{i}", nil)
    end
    assert_equal(rnd, @lb.item_count)
  end

  def test_get_current_empty_list
    lb = Newt::Listbox.new(0, 0, 0)
    assert_equal(false, lb.get_current)
  end

  def test_get
    assert_equal(['item3', 3], @lb.get(2))
  end

  def test_get_current_string
    lb = Newt::Listbox.new(0, 0, 0)
    1.upto(5) do |i|
      lb.append("item#{i}", "String no. #{i}")
    end
    lb.set_current(2)
    assert_equal('String no. 3', lb.get_current)
  end

  def test_clear
    assert_equal(5, @lb.item_count)
    @lb.clear
    assert_equal(0, @lb.item_count)
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

  def test_insert
    assert_equal(5, @lb.item_count)
    @lb.insert('inserted', 100, 3)
    assert_equal(6, @lb.item_count)
  end

  def test_get_selection
    @lb.select(2, Newt::FLAGS_SET)
    @lb.select(5, Newt::FLAGS_SET)
    assert_equal([2, 5], @lb.get_selection.sort)
  end

  def test_add_unusual_data
    time = Time.now
    @lb.append('item6', time)
    @lb.set_current(5)
    assert_equal(time, @lb.get_current)
  end
end
