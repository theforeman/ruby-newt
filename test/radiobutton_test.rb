require 'minitest/autorun'
require 'newt'

class TestRadiobutton < Minitest::Test
  def setup
    Newt::init
    @rb1 = Newt::RadioButton.new(1, 1, 'Button1', 1)
    @rb2 = Newt::RadioButton.new(1, 2, 'Button2', 0, @rb1)
  end

  def teardown
    Newt::finish
  end

  def test_invalid_argument_count
    assert_raises(ArgumentError) do
      Newt::RadioButton.new(1, 1)
    end

    assert_raises(ArgumentError) do
      Newt::RadioButton.new(1, 1, 'Text', 0, @rb1, nil)
    end
  end

  def test_get_current
    assert_equal(@rb1, @rb2.get_current)
  end

  def test_set_current
    @rb2.set_current
    assert_equal(@rb2, @rb1.get_current)
  end
end
