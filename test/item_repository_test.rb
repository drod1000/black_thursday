require 'simplecov'
SimpleCov.start
require 'minitest/autorun'
require 'minitest/pride'
require './lib/sales_engine'

class ItemRepositoryTest < Minitest::Test
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
    @repository = sales_engine.items
  end

  def test_it_can_create_item_repository
    assert repository
  end

  def test_all_returns_instances_of_items
    assert_instance_of Array, repository.all
  end

  def test_it_can_return_instance_of_item_with_matching_id
    assert repository.find_by_id(1)
    assert_instance_of Item, repository.find_by_id(1)
    assert repository.find_by_id(2)
    assert_instance_of Item, repository.find_by_id(2)
    assert_nil repository.find_by_id(50)
  end

  def test_it_can_return_instance_of_item_if_name_matches
    assert repository.find_by_name("Pencil")
    assert repository.find_by_name("Pen")
    assert_instance_of Item, repository.find_by_name("Pencil")
    assert_instance_of Item, repository.find_by_name("Pen")
    assert_nil repository.find_by_name("Bat")
  end

  def test_name_match_is_case_insensitive
    assert repository.find_by_name("Basketball")
    assert repository.find_by_name("basketball")
    assert repository.find_by_name("BASKETBALL")
    assert repository.find_by_name("BaSkEtBaLl")
    assert repository.find_by_name("Baseball")
    assert repository.find_by_name("baseball")
    assert repository.find_by_name("BASEBALL")
    assert repository.find_by_name("BaSeBaLl")
  end

  def test_it_can_return_items_that_match_description
    assert_equal 1, repository.find_all_with_description("You use it to carry your things").count
    assert_equal 2, repository.find_all_with_description("You use it to write things").count
    assert_equal [], repository.find_all_with_description("You won't find it!!")
  end

  def test_description_match_is_case_insensitive
    assert_equal 1, repository.find_all_with_description("YOU USE IT TO CARRY YOUR THINGS").count
    assert_equal 2, repository.find_all_with_description("YOU USE IT TO WRITE THINGS").count
  end

  def test_it_can_return_all_items_that_match_price
    assert repository.find_all_by_price(10)
    assert_equal 3, repository.find_all_by_price(10).count
    assert repository.find_all_by_price(40)
    assert_equal 1, repository.find_all_by_price(40).count
    assert_equal [], repository.find_all_by_price(1000)
  end

  def test_it_can_return_items_within_price_range
    assert_equal 4, repository.find_all_by_price_in_range(5..10).count
    assert_equal 2, repository.find_all_by_price_in_range(20..40).count
    assert_equal [], repository.find_all_by_price_in_range(100..110)
  end

  def test_it_can_return_items_matching_a_merchant_id
    assert_equal 2, repository.find_all_by_merchant_id(101).count
    assert_equal 2, repository.find_all_by_merchant_id(102).count
    assert_equal 1, repository.find_all_by_merchant_id(103).count
    assert_equal [], repository.find_all_by_merchant_id(999)
  end

  def test_that_an_item_repo_knows_who_its_parent_is
    assert_equal sales_engine, repository.parent
    assert_instance_of SalesEngine, repository.parent
  end

end
