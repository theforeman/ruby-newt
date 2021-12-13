# frozen_string_literal: true

require 'minitest/autorun'
require 'test_helper'
require 'newt'

class TestCompactButton < Minitest::Test
  def setup
    Newt.init
  end

  def teardown
    Newt.finish
  end

  def test_invalid_argument_count
    assert_raises(ArgumentError) do
      Newt::CompactButton.new(1, 1)
    end

    assert_raises(ArgumentError) do
      Newt::CompactButton.new(1, 1, 2, 100, 0, 0, 0, 0)
    end
  end

  def test_new
    Newt::CompactButton.new(1, 1, 'Exit')
  end
end

class TestCompactButtonUninitialized < Minitest::Test
  def test_new
    assert_init_exception do
      Newt::CompactButton.new(1, 1, 'Exit')
    end
  end
end
