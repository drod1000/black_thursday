require 'minitest/autorun'
require 'minitest/pride'
require './lib/sa_assistant'

class SAAssistantTest < Minitest::Test
  include SAAssistant
  attr_reader   :set_1,
                :set_2

  def setup
    @set_1 = [1,2,3,4,5,6,7,8,9,10]
    @set_2 = [5,10,12,15,18,30,45,48]
  end

  def test_it_can_get_sum
    assert_equal 55, sum(set_1)
    assert_equal 183, sum(set_2)
  end

  def test_it_can_get_mean
    assert_equal 5.5, mean(set_1)
    assert_equal 22.875, mean(set_2)
  end

  def test_it_can_get_squared_differences_sum
    assert_equal 82.5, squared_differences_sum(set_1)
    assert_equal 1860.875, squared_differences_sum(set_2)
  end

  def test_it_can_get_standard_deviation
    assert_equal 3.03, standard_deviation(set_1)
    assert_equal 16.30, standard_deviation(set_2)
  end

  def test_it_can_get_above_standard_deviation
    assert_equal [9,10], above_standard_deviation(set_1, 1)
    assert_equal [], above_standard_deviation(set_1, 2)
    assert_equal [45,48], above_standard_deviation(set_2, 1)
    assert_equal [], above_standard_deviation(set_2, 2)
  end

  def test_it_can_return_day_of_the_week
    assert_equal "Sunday", days_of_week[0]
    assert_equal "Wednesday", days_of_week[3]
  end

end
