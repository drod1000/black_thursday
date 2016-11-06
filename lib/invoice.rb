require 'time'
require 'pry'

class Invoice
  attr_reader   :id,
                :customer_id,
                :merchant_id,
                :status,
                :created_at,
                :updated_at,
                :parent

  def initialize(invoice_hash, parent=nil)
    @id = invoice_hash[:id].to_i
    @customer_id = invoice_hash[:customer_id].to_i
    @merchant_id = invoice_hash[:merchant_id].to_i
    @status = invoice_hash[:status].to_sym
    @created_at = Time.parse(invoice_hash[:created_at])
    @updated_at = Time.parse(invoice_hash[:updated_at])
    @parent = parent
  end

  def merchant
    parent.find_merchant(merchant_id)
  end

  def customer
    parent.find_customer(customer_id)
  end

  def transactions
    parent.find_transactions(id)
  end

  def items
    parent.find_items_by_invoice_id(id)
  end

  def is_paid_in_full?
    if transactions.length > 0
      transactions.all? do |transaction|
        transaction.result == "success"
      end
    else
      return false
    end
  end
end
