require 'minitest/autorun'
require 'newt'

class TestScale < Minitest::Test
  def test_invalid_columns
    assert_raises(RuntimeError) do
      Newt::Grid.new(0, 2)
    end
  end

  def test_invalid_rows
    assert_raises(RuntimeError) do
      Newt::Grid.new(2, 0)
    end
  end

  def test_invalid_field_position
    grid = Newt::Grid.new(2, 1)
    b = Newt::Button.new(-1, -1, 'Button')
    assert_raises(RuntimeError) do
      grid.set_field(0, 1, Newt::GRID_COMPONENT, b, 0, 0, 0, 0, 0, 0)
    end
  end
end
