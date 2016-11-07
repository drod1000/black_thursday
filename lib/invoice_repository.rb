require_relative 'invoice'
require 'csv'

class InvoiceRepository
  attr_reader   :contents,
                :invoices,
                :parent

  def initialize(path, parent = nil)
    @contents = CSV.open path, headers: true, header_converters: :symbol
    @parent = parent
    @invoices = contents.map {|line| Invoice.new(line, self)}
  end

  def all
    invoices
  end

  def find_by_id(id_number)
    all.find do |invoice|
      invoice.id == id_number
    end
  end

  def find_all_by_customer_id(customer_id)
    all.find_all do |invoice|
      invoice.customer_id == customer_id
    end
  end

  def find_all_by_merchant_id(merchant_id)
    all.find_all do |invoice|
      invoice.merchant_id == merchant_id
    end
  end

  def find_all_by_status(status)
    all.find_all do |invoice|
      invoice.status == status
    end
  end

  def find_merchant(merchant_id)
    parent.find_merchant(merchant_id)
  end

  def find_customer(customer_id)
    parent.find_customer(customer_id)
  end

  def find_transactions_by_invoice_id(invoice_id)
    parent.find_transactions_by_invoice_id(invoice_id)
  end

  def find_items_by_invoice_id(invoice_id)
    parent.find_items_by_invoice_id(invoice_id)
  end

  def find_invoice_items_by_invoice_id(invoice_id)
    parent.find_invoice_items_by_invoice_id(invoice_id)
  end

  def inspect
    "#<#{self.class} #{@invoices.size} rows>"
  end

end
