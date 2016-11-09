require 'simplecov'
SimpleCov.start
require 'minitest/autorun'
require 'minitest/pride'
require './lib/merchant_analyst'

class MerchantAnalystTest < Minitest::Test
  attr_reader   :merchant_analyst

  def setup
    sales_engine = SalesEngine.from_csv({
    :items => "./fixture/items.csv",
    :merchants => "./fixture/merchants.csv",
    :invoices => "./fixture/invoices.csv",
    :invoice_items => "./fixture/invoice_items.csv",
    :transactions => "./fixture/transactions.csv",
    :customers => "./fixture/customers.csv" })
    sales_analyst = SalesAnalyst.new(sales_engine)
    @merchant_analyst = MerchantAnalyst.new(sales_analyst)
  end

  def test_it_can_find_merchants_with_one_item
    assert_equal 4, merchant_analyst.merchants_with_only_one_item.count
  end

  def test_it_can_calculate_total_revenue_for_a_single_merchant
    assert_equal 210,merchant_analyst.revenue_by_merchant(102)
  end

  def test_it_can_return_top_merchants
    assert_equal 6, merchant_analyst.top_revenue_earners.count
  end

  def test_it_can_find_merchants_with_pending_invoices
    assert_equal 3, merchant_analyst.merchants_with_pending_invoices.count
  end

  def test_it_can_find_merchants_with_one_item_within_a_certain_month
    assert_equal 1, merchant_analyst.merchants_with_only_one_item_registered_in_month("May").count
  end

  def test_it_can_get_merchant_items
    hash = {1=>0, 2=>0}
    assert_equal hash, merchant_analyst.get_merchant_items(101)
  end

  def test_it_can_find_the_most_sold_item
    assert_equal 2, merchant_analyst.most_sold_item_for_merchant(101)[0].id
  end

  def test_it_can_find_the_best_item_for_merchant
    assert_equal 2, merchant_analyst.best_item_for_merchant(101).id
  end

end