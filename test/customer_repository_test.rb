require 'simplecov'
SimpleCov.start
require 'minitest/autorun'
require 'minitest/pride'
require './lib/sales_engine'

class CustomerRepositoryTest < Minitest::Test
  attr_reader   :repository,
                :sales_engine

  def setup
    @sales_engine = SalesEngine.from_csv({:customers => "./fixture/customers.csv"})
    @repository = sales_engine.customers
  end

  def test_it_can_create_customer_repository
    assert repository
  end

  def test_all_returns_instances_of_customers
    assert_instance_of Array, repository.all
  end

  def test_it_can_return_instance_of_customer_with_matching_id
    assert repository.find_by_id(1)
    assert_instance_of Customer, repository.find_by_id(1)
    assert repository.find_by_id(2)
    assert_instance_of Customer, repository.find_by_id(2)
    assert_nil repository.find_by_id(16)
  end

  def test_it_can_return_all_customers_that_match_first_name
    assert_equal 2, repository.find_all_by_first_name("John").length
    assert_equal 1, repository.find_all_by_first_name("Mary").length
    assert_equal [], repository.find_all_by_first_name("Delilah")
  end

  def test_it_can_return_all_customers_that_match_last_name
    assert_equal 2, repository.find_all_by_last_name("Smith").length
    assert_equal 1, repository.find_all_by_last_name("Johnson").length
    assert_equal [], repository.find_all_by_last_name("James")
  end

  def test_that_an_customer_repo_knows_who_its_parent_is
    assert_equal sales_engine, repository.parent
    assert_instance_of SalesEngine, repository.parent
  end

end