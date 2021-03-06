require 'simplecov'
SimpleCov.start
require 'minitest/autorun'
require 'minitest/pride'
require './lib/invoice_item'
require './lib/sales_engine'

class InvoiceItemTest < Minitest::Test
  attr_reader   :sales_engine,
                :invoice_item,
                :invoice_item_2

  def setup
    @sales_engine = SalesEngine.from_csv({
    :items => "./fixture/items.csv",
    :merchants => "./fixture/merchants.csv",
    :invoices => "./fixture/invoices.csv",
    :invoice_items => "./fixture/invoice_items.csv",
    :customers => "./fixture/customers.csv",
    :transactions => "./fixture/transactions.csv"
    })

    @invoice_item = InvoiceItem.new({
      :id => "1",
      :item_id => "1",
      :invoice_id => "101",
      :quantity => "2",
      :unit_price => "1099",
      :created_at => "2015-01-01 11:11:37 UTC",
      :updated_at => "2015-10-10 11:11:37 UTC"
    }, sales_engine.invoice_items)


    @invoice_item_2 = InvoiceItem.new({
      :id => "2",
      :item_id => "2",
      :invoice_id => "102",
      :quantity => "2",
      :unit_price => "2000",
      :created_at => "2015-01-01 11:11:37 UTC",
      :updated_at => "2015-10-10 11:11:37 UTC"
    }, sales_engine.invoice_items)
  end

  def test_it_can_create_an_invoice_item
    assert invoice_item
    assert invoice_item_2
  end

  def test_it_can_return_id
    assert_equal 1, invoice_item.id
    assert_equal 2, invoice_item_2.id
  end

  def test_it_can_return_item_id
    assert_equal 1, invoice_item.item_id
    assert_equal 2, invoice_item_2.item_id
  end

  def test_it_can_return_invoice_id
    assert_equal 101, invoice_item.invoice_id
    assert_equal 102, invoice_item_2.invoice_id
  end

  def test_it_can_return_quantity
    assert_equal 2, invoice_item.quantity
    assert_equal 2, invoice_item_2.quantity
  end

  def test_it_can_return_unit_price
    assert_equal 10.99, invoice_item.unit_price
    assert_equal 20.00, invoice_item_2.unit_price
    assert_instance_of BigDecimal, invoice_item.unit_price
    assert_instance_of BigDecimal, invoice_item_2.unit_price
  end

  def test_it_can_return_created_at_as_time
    assert_instance_of Time, invoice_item.created_at
    assert_instance_of Time, invoice_item_2.created_at
  end

  def test_it_can_return_updated_at_as_time
    assert_instance_of Time, invoice_item.updated_at
    assert_instance_of Time, invoice_item_2.updated_at
  end

  def test_that_an_invoice_item_knows_who_its_parent_is
    assert_instance_of InvoiceItemRepository, invoice_item.parent
  end

  def test_an_invoice_item_can_point_to_its_item
    invoice_item = sales_engine.invoice_items.find_by_id(1)
    assert_instance_of Item, invoice_item.item
    assert_equal 1, invoice_item.item.id
  end

end
