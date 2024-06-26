# frozen_string_literal: true

require 'minitest/autorun'
require 'test_helper'
require 'newt'

class TestTextbox < Minitest::Test
  def setup
    Newt.init
    @tb = Newt::Textbox.new(1, 1, 5, 3)
  end

  def teardown
    Newt.finish
  end

  def test_invalid_argument_count
    assert_raises(ArgumentError) do
      Newt::Textbox.new(1, 1)
    end

    assert_raises(ArgumentError) do
      Newt::Textbox.new(1, 1, 5, 3, 0, 0, 0)
    end
  end

  def test_new
    Newt::Textbox.new(1, 1, 5, 3)
  end

  def test_set_text
    @tb.set_text('Hello World!')
  end

  def test_set_height
    @tb.set_height(10)
    assert_equal(10, @tb.get_size[1])
  end

  def test_num_lines
    @tb.set_text("Line1\nLine2\nLine3\n")
    assert_equal(3, @tb.get_num_lines)
  end

  def test_set_colors
    @tb.set_colors(Newt::COLORSET_TEXTBOX, Newt::COLORSET_ACTTEXTBOX)
  end

  def test_flag_wrap
    @tb = Newt::Textbox.new(1, 1, 3, 3, Newt::FLAG_WRAP)
    @tb.set_text("Line1\nLine2\nLine3\n")
    assert_equal(6, @tb.get_num_lines)
  end

  def test_reflow
    @tb = Newt::TextboxReflowed.new(1, 1, LONG_TEXT, 10, 5, 5, 0)
    assert_operator(@tb.get_num_lines, :>, 1)
  end
end

class TestTextboxUninitialized < Minitest::Test
  def setup
    Newt.init
    @tb = Newt::Textbox.new(1, 1, 5, 3)
    Newt.finish
  end

  def test_new
    assert_init_exception do
      Newt::Textbox.new(1, 1, 5, 3)
    end
  end

  def test_new_reflowed
    assert_init_exception do
      Newt::TextboxReflowed.new(1, 1, LONG_TEXT, 10, 5, 5, 0)
    end
  end

  def test_set_text
    assert_init_exception do
      @tb.set_text('Hello World!')
    end
  end

  def test_set_height
    assert_init_exception do
      @tb.set_height(10)
    end
  end

  def test_num_lines
    assert_init_exception do
      @tb.get_num_lines
    end
  end

  def test_set_colors
    assert_init_exception do
      @tb.set_colors(Newt::COLORSET_TEXTBOX, Newt::COLORSET_ACTTEXTBOX)
    end
  end
end
