require 'minitest/autorun'
require 'newt'

class TestDelay < Minitest::Test
  def test_delay
    time1 = Time.now
    Newt.delay(500000)
    assert_in_delta(0.5, Time.now - time1, 0.001)
  end
end
