require_relative 'item'
require 'csv'

class ItemRepository
  attr_reader   :contents,
                :items,
                :parent

  def initialize(path, parent = nil)
    @contents = CSV.open path, headers: true, header_converters: :symbol
    @parent = parent
    @items = contents.map do |line|
      Item.new(line, self)
    end
  end

  def all
    items
  end

  def find_by_id(id_number)
    all.find do |item|
      item.id == id_number
    end
  end

  def find_by_name(name)
    all.find do |item|
      item.name.downcase == name.downcase
    end
  end

  def find_all_with_description(description)
    all.find_all do |item|
      item.description.downcase == description.downcase
    end
  end

  def find_all_by_price(price)
    all.find_all do |item|
      item.unit_price == price
    end
  end

  def find_all_by_price_in_range(range)
    all.find_all do |item|
      range.include?(item.unit_price_to_dollars)
    end
  end

  def find_all_by_merchant_id(merchant_id)
    all.find_all do |item|
      item.merchant_id.to_i == merchant_id
    end
  end

  def find_merchant(merchant_id)
    parent.find_merchant(merchant_id)
  end

  def inspect
    "#<#{self.class} #{all.size} rows>"
  end

end
