require_relative 'item_repository'
require_relative 'merchant_repository'
require_relative 'invoice_repository'
require_relative 'invoice_item_repository'
require_relative 'customer_repository'
require_relative 'transaction_repository'


require 'pry'

class SalesEngine
  attr_reader   :paths,
                :items,
                :merchants,
                :invoices,
                :invoice_items,
                :customers,
                :transactions

  def initialize(paths)
    @items = ItemRepository.new(paths[:items], self)
    @merchants = MerchantRepository.new(paths[:merchants], self)
    @invoices = InvoiceRepository.new(paths[:invoices], self)
    @invoice_items = InvoiceItemRepository.new(paths[:invoice_items], self)
    @customers = CustomerRepository.new(paths[:customers], self)
    @transactions = TransactionRepository.new(paths[:transactions], self)
  end

  def self.from_csv(paths)
    SalesEngine.new(paths)
  end

  def find_merchant(merchant_id)
    merchants.find_by_id(merchant_id)
  end

  def find_customer(customer_id)
    customers.find_by_id(customer_id)
  end

  def find_transactions(invoice_id)
    transactions.find_all_by_invoice_id(invoice_id)
  end

  def find_invoice(invoice_id)
    invoices.find_by_id(invoice_id)
  end

  def find_invoice_items_by_invoice_id(invoice_id)
    invoice_items.find_all_by_invoice_id(invoice_id)
  end

  def find_items_by_merchant_id(merchant_id)
    items.find_all_by_merchant_id(merchant_id)
  end

  def find_item_by_invoice_item(item_id)
    items.find_by_id(item_id)
  end

  def find_invoices_by_merchant_id(merchant_id)
    invoices.find_all_by_merchant_id(merchant_id)
  end

  def find_customers_by_merchant_id(merchant_id)
    invoices = find_invoices_by_merchant_id(merchant_id)
    customers = invoices.map do |invoice|
      invoice.customer
    end
    customers.uniq
  end

  def find_items_by_invoice_id(invoice_id)
    invoice_items = find_invoice_items_by_invoice_id(invoice_id)
    items = invoice_items.map do |invoice_item|
      invoice_item.item
    end
    items.uniq
  end
end
