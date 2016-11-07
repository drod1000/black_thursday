require 'simplecov'
SimpleCov.start
require 'minitest/autorun'
require 'minitest/pride'
require './lib/sales_engine'

class InvoiceItemRepositoryTest < Minitest::Test
  attr_reader   :repository,
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
    @repository = sales_engine.invoice_items
  end

  def test_it_can_create_invoice_repository
    assert repository
  end

  def test_all_returns_instances_of_invoices
    assert_instance_of Array, repository.all
  end

  def test_it_can_return_instance_of_invoice_with_matching_id
    assert repository.find_by_id(1)
    assert_instance_of InvoiceItem, repository.find_by_id(1)
    assert repository.find_by_id(2)
    assert_instance_of InvoiceItem, repository.find_by_id(2)
    assert_nil repository.find_by_id(100)
  end

  def test_it_can_return_all_invoices_that_match_item_id
    assert_equal 6, repository.find_all_by_item_id(1).length
    assert_equal 3, repository.find_all_by_item_id(2).length
    assert_equal [], repository.find_all_by_item_id(16)
  end

  def test_it_can_return_all_invoices_that_match_invoice_id
    assert_equal 1, repository.find_all_by_invoice_id(1).length
    assert_equal 2, repository.find_all_by_invoice_id(2).length
    assert_equal [], repository.find_all_by_invoice_id(16)
  end

  def test_that_an_invoice_repo_knows_who_its_parent_is
    assert_equal sales_engine, repository.parent
    assert_instance_of SalesEngine, repository.parent
  end

end
