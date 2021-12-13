# frozen_string_literal: true

require 'minitest/autorun'
require 'test_helper'
require 'newt'

class TestButton < Minitest::Test
  def setup
    Newt.init
  end

  def teardown
    Newt.finish
  end

  def test_new
    Newt::Button.new(1, 1, 'Exit')
  end
end

class TestButtonUninitialized < Minitest::Test
  def test_new
    assert_init_exception do
      Newt::Button.new(1, 1, 'Exit')
    end
  end
end
