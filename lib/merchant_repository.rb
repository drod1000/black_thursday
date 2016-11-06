require_relative 'merchant'
require 'csv'
require 'pry'

class MerchantRepository

  attr_reader   :contents,
                :merchants,
                :parent

  def initialize(path, parent=nil)
    @contents = CSV.open path, headers: true, header_converters: :symbol
    @parent = parent
    @merchants = contents.map {|line| Merchant.new(line, self)}
  end

  def all
    merchants
  end

  def find_by_id(id_number)
    all.find {|merchant| merchant.id == id_number}
  end

  def find_by_name(name)
    all.find do |merchant|
      merchant.name.downcase == name.downcase
    end
  end

  def find_all_by_name(partial_search)
    all.find_all do |merchant|
      merchant.name.downcase.include?(partial_search.downcase)
    end
  end

  def find_items_by_merchant_id(merchant_id)
    parent.find_items_by_merchant_id(merchant_id)
  end

  def find_invoices_by_merchant_id(merchant_id)
    parent.find_invoices_by_merchant_id(merchant_id)
  end

  def find_customers_by_merchant_id(merchant_id)
    parent.find_customers_by_merchant_id(merchant_id)
  end

  def inspect
    "#<#{self.class} #{all.size} rows>"
  end

end
