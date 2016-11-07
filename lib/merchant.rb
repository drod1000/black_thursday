require 'time'

class Merchant

  attr_reader   :id,
                :name,
                :parent,
                :created_at,
                :updated_at

  def initialize(hash, parent=nil)
    @id = hash[:id].to_i
    @name = hash[:name]
    @parent = parent
    @created_at = Time.parse(hash[:created_at])
    @updated_at = Time.parse(hash[:updated_at])
  end

  def items
    parent.find_items_by_merchant_id(id)
  end

  def invoices
    parent.find_invoices_by_merchant_id(id)
  end

  def customers
    parent.find_customers_by_merchant_id(id)
  end

end
