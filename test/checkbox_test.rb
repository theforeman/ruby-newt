require 'minitest/autorun'
require 'newt'

class TestCheckbox < Minitest::Test
  def setup
    Newt::init
    @cb = Newt::Checkbox.new(0, 0, 'Checkbox')
  end

  def teardown
    Newt::finish
  end

  def test_invalid_argument_count
    assert_raises(ArgumentError) do
      Newt::Checkbox.new(0, 0)
    end

    assert_raises(ArgumentError) do
      Newt::Checkbox.new(0, 0, 'Checkbox', '*', ' *', nil)
    end
  end

  def test_get_value
    assert_equal(' ', @cb.get)
  end

  def test_get_default_value
    cb = Newt::Checkbox.new(0, 0, 'Checkbox', 'X')
    assert_equal('X', cb.get)
  end

  def test_with_sequence
    cb = Newt::Checkbox.new(0, 0, 'Checkbox', nil, 'AB')
    assert_equal('A', cb.get)
  end

  def test_set_value
    @cb.set('*')
    assert_equal('*', @cb.get)
  end
end
