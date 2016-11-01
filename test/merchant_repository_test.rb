require 'minitest/autorun'
require 'minitest/pride'
require './lib/merchant_repository'

class MerchantRepositoryTest < Minitest::Test

  def test_it_can_create_merchant_repository
    repository = MerchantRepository.new
  end

  def test_it_can_find_all_instances_of_Merchant
    repository = MerchantRepository.new

    repository.instance_of? Merchant
  end


  def test_it_can_find_by_id
    repository = MerchantRepository.new

    assert repository.id(1234105)
    assert_instance_of Merchant, repository.id(1234105)
    assert repository.id(12334112)
    assert_instance_of Merchant, repository.id(12334112)
    assert_nil repository.id(12345678)
  end

  def test_it_can_find_by_case_insensitive_name
    repository = MerchantRepository.new

    assert_instance_of Merchant, repository.name("shopin1901")
    assert_instance_of Merchant, repository.name("SHOPIN1901")
    assert_instance_of Merchant, repository.name("Shopin1901")
    assert_instance_of Merchant, repository.name("candisart")
    assert_instance_of Merchant, repository.name("CANDISART")
    assert_instance_of Merchant, repository.name("Candisart")
    assert_nil, repository.name("Amazon")
  end

  def test_it_can_find_all_by_case_insensitive_name
    repository = MerchantRepository.new

    assert_instance_of Merchant, repository.name("shop")
    assert_instance_of Merchant, repository.name("SHOPIN")
    assert_instance_of Merchant, repository.name("1901")
    assert_instance_of Merchant, repository.name("CANDI")
    assert_instance_of Merchant, repository.name("Art")
    assert_instance_of Merchant, repository.name("sart")
    assert_nil, repository.name("Amazon")
  end
end
