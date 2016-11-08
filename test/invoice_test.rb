require 'simplecov'
SimpleCov.start
require 'minitest/autorun'
require 'minitest/pride'
require './lib/invoice'
require './lib/sales_engine'
require 'pry'

class InvoiceTest < Minitest::Test
  attr_reader   :sales_engine,
                :invoice,
                :invoice_2

  def setup
    @sales_engine = SalesEngine.from_csv({
      :items => "./fixture/items.csv",
      :merchants => "./fixture/merchants.csv",
      :invoices => "./fixture/invoices.csv",
      :invoice_items => "./fixture/invoice_items.csv",
      :transactions => "./fixture/transactions.csv",
      :customers => "./fixture/customers.csv"
    })

    @invoice = Invoice.new({
      :id => "1",
      :customer_id => "1",
      :merchant_id => "101",
      :status => "pending",
      :created_at => "2015-01-01 11:11:37 UTC",
      :updated_at => "2015-10-10 11:11:37 UTC",
    }, sales_engine.invoices)

    @invoice_2 = Invoice.new({
      :id => "2",
      :customer_id => "2",
      :merchant_id => "102",
      :status => "pending",
      :created_at => "2015-01-01 11:11:37 UTC",
      :updated_at => "2015-10-10 11:11:37 UTC",
    }, sales_engine.invoices)
  end

  def test_it_can_create_an_invoice
    assert invoice
    assert invoice_2
  end

  def test_it_can_return_invoice_id
    assert_equal 1, invoice.id
    assert_equal 2, invoice_2.id
  end

  def test_it_can_return_customer_id
    assert_equal 1, invoice.customer_id
    assert_equal 2, invoice_2.customer_id
  end

  def test_it_can_return_merchant_id
    assert_equal 101, invoice.merchant_id
    assert_equal 102, invoice_2.merchant_id
  end

  def test_it_can_return_status
    assert_equal :pending, invoice.status
    assert_equal :pending, invoice_2.status
  end

  def test_it_can_return_created_at_as_time
    assert_instance_of Time, invoice.created_at
    assert_instance_of Time, invoice_2.created_at
  end

  def test_it_can_return_updated_at_as_time
    assert_instance_of Time, invoice.updated_at
    assert_instance_of Time, invoice_2.updated_at
  end

  def test_that_an_invoice_knows_who_its_parent_is
    assert_instance_of InvoiceRepository, invoice.parent
  end

  def test_an_invoice_can_point_to_its_merchant
    invoice = sales_engine.invoices.find_by_id(1)
    assert_instance_of Merchant, invoice.merchant
    assert_equal 101, invoice.merchant.id
  end

  def test_an_invoice_can_point_to_its_transactions
    invoice = sales_engine.invoices.find_by_id(1)
    assert_equal 3, invoice.transactions.count
  end

  def test_an_invoice_can_point_to_its_customer
    invoice = sales_engine.invoices.find_by_id(4)
    assert_instance_of Customer, invoice.customer
    assert_equal 4, invoice.customer.id
  end

  def test_an_invoice_can_point_to_its_items
    invoice = sales_engine.invoices.find_by_id(2)
    assert_equal 2, invoice.items.count
  end

  def test_that_an_invoice_can_point_to_its_invoice_items
    invoice = sales_engine.invoices.find_by_id(2)
    assert_equal 2, invoice.invoice_items.count
  end

  def test_an_invoice_can_confirm_whether_its_paid_in_full
    invoice = sales_engine.invoices.find_by_id(2)
    assert invoice.is_paid_in_full?
    invoice = sales_engine.invoices.find_by_id(14)
    refute invoice.is_paid_in_full?
  end

  def test_that_an_invoice_can_return_its_total
    invoice = sales_engine.invoices.find_by_id(2)
    assert_equal 15, invoice.total
    invoice = sales_engine.invoices.find_by_id(14)
    refute invoice.total
  end

end
