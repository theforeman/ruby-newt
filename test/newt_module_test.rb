# frozen_string_literal: true

require 'minitest/autorun'
require 'test_helper'
require 'newt'

class TestNewtModule < Minitest::Test
  def test_delay
    time = Time.now
    Newt.delay(500000)
    assert_in_delta(0.5, Time.now - time, 0.001)
  end

  def test_reflow_text
    _t, w, h = Newt.reflow_text(LONG_TEXT, 10, 5, 5)
    assert_equal(14, w)
    assert_equal(3,  h)
  end
end
