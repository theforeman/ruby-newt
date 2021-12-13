# frozen_string_literal: true

require 'minitest/autorun'
require 'test_helper'
require 'newt'

class TestLabel < Minitest::Test
  def setup
    Newt.init
    @l = Newt::Label.new(1, 1, 'Label')
  end

  def teardown
    Newt.finish
  end

  def test_invalid_argument_count
    assert_raises(ArgumentError) do
      Newt::Label.new(1, 1)
    end

    assert_raises(ArgumentError) do
      Newt::Label.new(1, 1, 2, 100, 0, 0, 0, 0)
    end
  end

  def test_new
    Newt::Label.new(1, 1, 'Label')
  end

  def test_set_text
    @l.set_text('New Label')
  end

  def test_set_colors
    @l.set_colors(Newt::COLORSET_LABEL)
  end
end

class TestLabelUninitialized < Minitest::Test
  def setup
    Newt.init
    @l = Newt::Label.new(1, 1, 'Label')
    Newt.finish
  end

  def test_new
    assert_init_exception do
      Newt::Label.new(1, 1, 'Exit')
    end
  end

  def test_set_text
    assert_init_exception do
      @l.set_text('New Label')
    end
  end

  def test_set_colors
    assert_init_exception do
      @l.set_colors(Newt::COLORSET_LABEL)
    end
  end
end
