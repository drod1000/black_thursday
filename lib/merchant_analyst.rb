require_relative 'sales_analyst'

class MerchantAnalyst
  attr_reader   :sales_analyst

  def initialize(sales_analyst)
    @sales_analyst = sales_analyst
  end

  def sales_engine
    sales_analyst.sales_engine
  end

  def merchants
    sales_analyst.sales_engine.merchants
  end

  def items
    sales_analyst.sales_engine.items
  end

  def merchants_with_only_one_item
    merchants.all.find_all do |merchant|
      merchant.items.count == 1
    end
  end

  def revenue_by_merchant(merchant_id)
    invoices = sales_engine.find_invoices_by_merchant_id(merchant_id)
    invoices.reduce(0) do |total, invoice|
      total += invoice.total if invoice.total
      total
    end
  end

  def merchants_ranked_by_revenue
    merchants.all.sort_by do |merchant|
      revenue_by_merchant(merchant.id)
    end.reverse.uniq
  end

  def top_revenue_earners(number = 20)
    merchants_ranked_by_revenue[0..number-1]
  end

  def merchants_with_pending_invoices
    merchants.all.find_all do |merchant|
      merchant.invoices.any? do |invoice|
        merchant unless invoice.is_paid_in_full?
      end
    end
  end

  def merchants_with_only_one_item_registered_in_month(month)
    find_month = merchants.all.find_all do |merchant|
      merchant.created_at.month == Time.parse(month).month
    end
    find_month.find_all do |merchant|
      merchant.items.count == 1
    end
  end

  def get_merchant_items(merchant_id)
    hash = Hash.new(0)
    find_merchant(merchant_id).items.each_with_object(hash) do |item, hash|
      hash[item.id] = 0
    end
  end

  def find_merchant(merchant_id)
    merchants.find_by_id(merchant_id)
  end

  def get_best_items(hash)
    max = hash.values.max
    top = Hash[hash.select {|key, value| value == max}]
    top.map {|key, value| items.find_by_id(key)}
  end

  def check_invoice_quantity(items, invoice)
    if invoice.is_paid_in_full?
      invoice.invoice_items.each do |invoice_item|
        items[invoice_item.item_id] += invoice_item.quantity
      end
    end
  end

  def check_invoice_total(items, invoice)
    if invoice.is_paid_in_full?
      invoice.invoice_items.each do |invoice_item|
        items[invoice_item.item_id] += invoice_item.total
      end
    end
  end

  def most_sold_item_for_merchant(merchant_id)
    items_sold = get_merchant_items(merchant_id)
    find_merchant(merchant_id).invoices.each do |invoice|
      check_invoice_quantity(items_sold, invoice)
    end
    get_best_items(items_sold)

  end

  def best_item_for_merchant(merchant_id)
    items_sold = get_merchant_items(merchant_id)
    find_merchant(merchant_id).invoices.each do |invoice|
      check_invoice_total(items_sold, invoice)
    end
    max = items_sold.values.max
    items.find_by_id(items_sold.key(max))
  end
end
