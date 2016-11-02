require 'minitest/autorun'
require 'minitest/pride'
require './lib/sales_engine'

class SalesEngineTest < Minitest::Test
  attr_reader   :sales_engine

  def setup
    @sales_engine = SalesEngine.from_csv({
      :items => "./fixture/items.csv"
    })
  end

  def test_it_can_create_sales_engine
    assert sales_engine
  end

  def test_it_has_instance_of_item_repo
    assert sales_engine.items
    assert_instance_of ItemRepository, sales_engine.items
  end

  def test_it_has_instance_of_merchant_repo
    skip
    assert sales_engine.merchants
    assert_instance_of MerchantRepository, sales_engine.merchants
  end
end