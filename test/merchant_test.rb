require 'simplecov'
SimpleCov.start
require 'minitest/autorun'
require 'minitest/pride'
require './lib/sales_engine'

class MerchantTest < Minitest::Test
  attr_reader   :merchant,
                :repository,
                :sales_engine

  def setup
    @sales_engine = SalesEngine.from_csv({
      :items => "./fixture/items.csv",
      :merchants => "./fixture/merchants.csv",
      :invoices => "./fixture/invoices.csv",
      :invoice_items => "./fixture/invoice_items.csv",
      :customers => "./fixture/customers.csv",
      :transactions => "./fixture/transactions.csv"
      })

    @merchant = Merchant.new({
    :id => 5,
    :name => "Turing School",
    :created_at => "2010-11-11",
    :updated_at => "2011-11-11"
    }, sales_engine.merchants)
  end

  def test_it_can_create_a_merchant
    assert merchant
  end

  def test_it_can_return_id
    assert_equal 5, merchant.id
  end

  def test_it_can_return_name
    assert_equal "Turing School", merchant.name
  end

  def test_that_a_merchant_knows_who_its_parent_is
    assert_instance_of MerchantRepository, merchant.parent
  end

  def test_a_merchant_can_point_to_its_items
    merchant = sales_engine.merchants.find_by_id(101)
    assert_equal 2, merchant.items.count
  end

  def test_a_merchant_can_point_to_its_invoices
    merchant = sales_engine.merchants.find_by_id(101)
    assert_equal 2, merchant.invoices.count
  end

  def test_a_merchant_can_point_to_its_customers
    merchant = sales_engine.merchants.find_by_id(101)
    assert_equal 2, merchant.customers.count
  end

end
