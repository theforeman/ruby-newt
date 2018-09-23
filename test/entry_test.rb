require 'minitest/autorun'
require 'newt'

class TestEntry < Minitest::Test
  def setup
    @initial_text = 'initial text'
    @e = Newt::Entry.new(0, 0, @initial_text, 20)
  end

  def test_invalid_argument_count
    assert_raises(ArgumentError) do
      Newt::Checkbox.new(0, 0)
    end

    assert_raises(ArgumentError) do
      Newt::Checkbox.new(0, 0, @initial_text, 20, 0, nil)
    end
  end

  def test_get
    assert_equal(@initial_text, @e.get)
  end

  def test_get_cursor_position
    assert_equal(@initial_text.length, @e.get_cursor_position)
  end

  def test_set
    text = 'new text'
    @e.set(text, 0)
    assert_equal(text, @e.get)
    assert_equal(0, @e.get_cursor_position)
  end

  def test_set_cursor_at_end
    text = 'this is a longer string'
    @e.set('this is a longer string', 1)
    assert_equal(text.length, @e.get_cursor_position)
  end
end
