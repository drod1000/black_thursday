require 'time'

class Transaction
  attr_reader   :id,
                :invoice_id,
                :credit_card_number,
                :credit_card_expiration_date,
                :result,
                :created_at,
                :updated_at,
                :parent

  def initialize(hash, parent=nil)
    @id = hash[:id].to_i
    @invoice_id = hash[:invoice_id].to_i
    @credit_card_number = hash[:credit_card_number].to_i
    @credit_card_expiration_date = hash[:credit_card_expiration_date]
    @result = hash[:result]
    @created_at = Time.parse(hash[:created_at])
    @updated_at = Time.parse(hash[:updated_at])
    @parent = parent
  end

  def invoice
    parent.find_invoice(invoice_id)
  end

end
