require 'simplecov'
SimpleCov.start
require 'minitest/autorun'
require 'minitest/pride'
require './lib/transaction'
require './lib/sales_engine'

class TransactionTest < Minitest::Test
  attr_reader   :transaction,
                :transaction_2,
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

    @transaction = Transaction.new({
      :id => 3,
      :invoice_id => 4,
      :credit_card_number => "2121212121212121",
      :credit_card_expiration_date => "0118",
      :result => "success",
      :created_at => "2015-01-01 11:11:37 UTC",
      :updated_at => "2015-10-10 11:11:37 UTC",
    }, sales_engine.transactions)

    @transaction_2 = Transaction.new({
      :id => 6,
      :invoice_id => 8,
      :credit_card_number => "4242424242424242",
      :credit_card_expiration_date => "0220",
      :result => "failure",
      :created_at => "2015-01-01 11:11:37 UTC",
      :updated_at => "2015-10-10 11:11:37 UTC",
    }, sales_engine.transactions)
  end

  def test_it_can_create_a_transaction
    assert transaction
    assert transaction_2
  end

  def test_it_can_return_id
    assert_equal 3, transaction.id
    assert_equal 6, transaction_2.id
  end

  def test_it_can_return_credit_card_number
    assert_equal 2121212121212121, transaction.credit_card_number
    assert_equal 4242424242424242, transaction_2.credit_card_number
  end

  def test_it_can_return_expiration_date
    assert_equal "0118", transaction.credit_card_expiration_date
    assert_equal "0220", transaction_2.credit_card_expiration_date
  end

  def test_it_can_return_result
    assert_equal "success", transaction.result
    assert_equal "failure", transaction_2.result
  end


  def test_it_can_return_created_at_as_time
    assert_instance_of Time, transaction.created_at
    assert_instance_of Time, transaction_2.created_at
  end

  def test_it_can_return_updated_at_as_time
    assert_instance_of Time, transaction.updated_at
    assert_instance_of Time, transaction_2.updated_at
  end

  def test_that_a_transaction_knows_who_its_parent_is
    assert_instance_of TransactionRepository, transaction.parent
  end

  def test_that_a_transaction_can_point_to_its_invoice
    transaction = sales_engine.transactions.find_by_id(1)
    assert_instance_of Invoice, transaction.invoice
    assert_equal 1, transaction.invoice.id
  end

end
