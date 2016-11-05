require_relative 'transaction'
require 'csv'

class TransactionRepository
  attr_reader   :contents,
                :transactions,
                :parent

  def initialize(path, parent = nil)
    @contents = CSV.open path, headers: true, header_converters: :symbol
    @parent = parent
    @transactions = contents.map {|line| Transaction.new(line, self)}
  end

  def all
    transactions
  end

  def find_by_id(id_number)
    all.find  {|transaction| transaction.id == id_number}
  end

  def find_all_by_invoice_id(invoice_id)
    all.find_all {|transaction| transaction.invoice_id == invoice_id}
  end

  def find_all_by_credit_card_number(credit_card_number)
    all.find_all do |transaction|
      transaction.credit_card_number == credit_card_number
    end
  end

  def find_all_by_result(result)
    all.find_all {|transaction| transaction.result == result}
  end

  def find_invoice(invoice_id)
    parent.find_invoice(invoice_id)
  end

  def inspect
    "#<#{self.class} #{all.size} rows>"
  end

end