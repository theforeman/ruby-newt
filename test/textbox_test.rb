require 'minitest/autorun'
require 'newt'

class TestTextbox < Minitest::Test
  def setup
    @tb = Newt::Textbox.new(1, 1, 5, 3)
  end

  def test_invalid_argument_count
    assert_raises(ArgumentError) do
      Newt::Textbox.new(1, 1)
    end

    assert_raises(ArgumentError) do
      Newt::Textbox.new(1, 1, 5, 3, 0, 0, 0)
    end
  end

  def test_num_lines
    @tb.set_text("Line1\nLine2\nLine3\n")
    assert_equal(3, @tb.get_num_lines)
  end

  def test_flag
    @tb = Newt::Textbox.new(1, 1, 3, 3, Newt::FLAG_WRAP)
    @tb.set_text("Line1\nLine2\nLine3\n")
    assert_equal(6, @tb.get_num_lines)
  end

  def test_set_height
    @tb.set_height(10)
    assert_equal(10, @tb.get_size[1])
  end

  def test_reflow
    text = 'This is a very long line with no newlines...'
    @tb = Newt::TextboxReflowed.new(1, 1, text, 10, 5, 5, 0)
    assert_operator(@tb.get_num_lines, :>, 1)
  end
end
