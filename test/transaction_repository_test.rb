require 'simplecov'
SimpleCov.start
require 'minitest/autorun'
require 'minitest/pride'
require './lib/sales_engine'

class TransactionRepositoryTest < Minitest::Test
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
    @repository = sales_engine.transactions
  end

  def test_it_can_create_transaction_repository
    assert repository
  end

  def test_all_returns_instances_of_transactions
    assert_instance_of Array, repository.all
  end

  def test_it_can_return_instance_of_transaction_with_matching_id
    assert repository.find_by_id(1)
    assert_instance_of Transaction, repository.find_by_id(1)
    assert repository.find_by_id(2)
    assert_instance_of Transaction, repository.find_by_id(2)
    assert_nil repository.find_by_id(25)
  end

  def test_it_can_return_all_transactions_that_match_invoice_id
    assert_equal 3, repository.find_all_by_invoice_id(1).count
    assert_equal 2, repository.find_all_by_invoice_id(2).count
    assert_equal [], repository.find_all_by_invoice_id(25)
  end

  def test_it_can_return_all_transactions_that_match_credit_card_number
    assert 3, repository.find_all_by_credit_card_number(1234567891234567).count
    assert 2, repository.find_all_by_credit_card_number(9876543210987654).count
    assert_equal [], repository.find_all_by_credit_card_number(1111111111111111)
  end

  def test_it_can_return_all_transactions_that_match_result
    assert_equal 12, repository.find_all_by_result("success").count
    assert_equal 8, repository.find_all_by_result("failure").count
  end

  def test_that_a_transaction_repo_knows_who_its_parent_is
    assert_equal sales_engine, repository.parent
    assert_instance_of SalesEngine, repository.parent
  end

end
