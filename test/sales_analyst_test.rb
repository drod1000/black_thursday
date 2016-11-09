require 'simplecov'
SimpleCov.start
require 'minitest/autorun'
require 'minitest/pride'
require './lib/sales_analyst'

class SalesAnalystTest < Minitest::Test
  attr_reader   :sales_analyst

  def setup
    sales_engine = SalesEngine.from_csv({
    :items => "./fixture/items.csv",
    :merchants => "./fixture/merchants.csv",
    :invoices => "./fixture/invoices.csv",
    :invoice_items => "./fixture/invoice_items.csv",
    :transactions => "./fixture/transactions.csv",
    :customers => "./fixture/customers.csv" })
    @sales_analyst = SalesAnalyst.new(sales_engine)
  end

  def test_it_can_create_sales_analyst
    assert sales_analyst
  end

  def test_it_has_a_sales_engine_instance
    assert_instance_of SalesEngine, sales_analyst.sales_engine
  end

  def test_it_can_return_total_number_of_merchants
    assert_equal 6, sales_analyst.total_merchants
  end

  def test_it_can_return_average_items_per_merchant
    assert_equal 1.33, sales_analyst.average_items_per_merchant
  end

  def test_it_can_return_average_number_of_invoices_per_merchant
    assert_equal 2.50, sales_analyst.average_invoices_per_merchant
  end

  def test_it_can_return_array_with_the_number_of_items_for_each_merchant
    assert_equal [1,1,1,1,2,2], sales_analyst.collect_items_per_merchant.sort
  end

  def test_it_can_return_array_with_the_number_of_invoices_for_each_merchant
    assert_equal [2,2,2,2,3,4], sales_analyst.collect_invoices_per_merchant.sort
  end

  def test_it_can_return_standard_deviations_for_items_and_invoices
    assert_equal 0.52, sales_analyst.average_items_per_merchant_standard_deviation
    assert_equal 0.84, sales_analyst.average_invoices_per_merchant_standard_deviation
  end

  def test_it_can_return_array_of_items_given_merchant_id
    assert_instance_of Array, sales_analyst.items_given_merchant_id(101)
    assert_instance_of Array, sales_analyst.items_given_merchant_id(102)
    assert_equal 2, sales_analyst.items_given_merchant_id(101).count
    assert_equal 2, sales_analyst.items_given_merchant_id(102).count
  end

  def test_it_can_determine_average_price_per_merchant
    assert_equal 7.50, sales_analyst.average_item_price_for_merchant(101)
    assert_equal 15.00, sales_analyst.average_item_price_for_merchant(102)
  end

  def test_it_can_find_the_average_average_price_of_all_merchants
    assert_equal 24.58, sales_analyst.average_average_price_per_merchant
  end

  def test_it_can_retrieve_all_item_prices
    assert_equal [5,10,10,10,15,20,40,60], sales_analyst.get_all_prices.sort
  end

  def test_it_can_find_golden_prices
    assert_equal 1, sales_analyst.golden_prices.count
  end

  def test_it_can_return_a_golden_item
    assert_equal 1, sales_analyst.golden_items.count
  end

  def test_golden_items_returns_an_array
    assert Array, sales_analyst.golden_items.class
  end

  def test_it_can_calculate_number_of_items_for_every_merchant
    assert_equal [1,1,1,1,2,2], sales_analyst.number_of_items_for_every_merchant.sort
  end

  def test_it_can_calculate_merchants_with_high_item_count
    assert_equal 2, sales_analyst.merchants_with_high_item_count.count
  end

  def test_it_can_calculate_top_merchants_by_invoice_count
    assert_equal 0, sales_analyst.top_merchants_by_invoice_count.count
  end

  def test_it_can_calculate_bottom_merchants_by_invoice_count
    assert_equal 0, sales_analyst.bottom_merchants_by_invoice_count.count
  end

  def test_it_can_find_invoice_status
    hash = {:pending=>4, :shipped=>9, :returned=>2}
    assert_equal hash, sales_analyst.find_invoice_status
  end

  def test_it_can_calculate_invoice_status_percentage
    assert_equal 26.67, sales_analyst.invoice_status(:pending)
    assert_equal 60.00, sales_analyst.invoice_status(:shipped)
    assert_equal 13.33, sales_analyst.invoice_status(:returned)
  end

  def test_it_can_return_number_of_days
    assert_equal [1,2,2,1,1,6,2], sales_analyst.invoices_per_day
  end

  def test_it_can_find_high_days_of_week
    assert_equal ["Friday"], sales_analyst.top_days_by_invoice_count
  end

  def test_it_can_calculate_revenue_by_date
    assert_equal 35, sales_analyst.total_revenue_by_date(Time.parse("2011-11-11"))
  end

  def test_it_can_find_merchants_with_one_item
    assert_equal 4, sales_analyst.merchants_with_only_one_item.count
  end

  def test_it_can_calculate_total_revenue_for_a_single_merchant
    assert_equal 210,sales_analyst.revenue_by_merchant(102)
  end

  def test_it_can_return_top_merchants
    assert_equal 6, sales_analyst.top_revenue_earners.count
  end

  def test_it_can_find_merchants_with_pending_invoices
    assert_equal 3, sales_analyst.merchants_with_pending_invoices.count
  end

  def test_it_can_find_merchants_with_one_item_within_a_certain_month
    assert_equal 1, sales_analyst.merchants_with_only_one_item_registered_in_month("May").count
  end

  def test_it_can_find_the_most_sold_item
    assert_equal 2, sales_analyst.most_sold_item_for_merchant(101)[0].id
  end

  def test_it_can_find_the_best_item_for_merchant
    assert_equal 2, sales_analyst.best_item_for_merchant(101).id
  end

end
