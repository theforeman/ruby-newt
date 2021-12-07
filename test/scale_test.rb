require 'minitest/autorun'
require 'newt'

class TestScale < Minitest::Test
  def setup
    Newt::init
    @s = Newt::Scale.new(1, 1, 2, 100)
  end

  def teardown
    Newt::finish
  end

  def test_invalid_argument_count
    assert_raises(ArgumentError) do
      Newt::Scale.new(1, 1)
    end

    assert_raises(ArgumentError) do
      Newt::Scale.new(1, 1, 2, 100, 0, 0, 0, 0)
    end
  end
end
