require_relative 'invoice_item'
require 'csv'

class InvoiceItemRepository
  attr_reader   :contents,
                :invoice_items,
                :parent

  def initialize(path, parent = nil)
    @contents = CSV.open path, headers: true, header_converters: :symbol
    @parent = parent
    @invoice_items = contents.map do |line|
      InvoiceItem.new(line, self)
    end
  end

  def all
    invoice_items
  end

  def find_by_id(id_number)
    all.find {|invoice_item| invoice_item.id == id_number}
  end

  def find_all_by_item_id(item_id)
    all.find_all {|invoice_item| invoice_item.item_id == item_id}
  end

  def find_all_by_invoice_id(invoice_id)
    all.find_all {|invoice_item| invoice_item.invoice_id == invoice_id}
  end

  def find_item_by_invoice_item(item_id)
    parent.find_item_by_invoice_item(item_id)
  end

  def inspect
    "#<#{self.class} #{all.size} rows>"
  end

end