require_relative 'sales_engine'
require_relative 'sa_assistant'
require 'pry'

class SalesAnalyst
  include SAAssistant
  attr_reader   :sales_engine,
                :items,
                :merchants,
                :invoices,
                :invoice_items,
                :customers,
                :transactions


  def initialize(sales_engine)
    @sales_engine = sales_engine
    @items = sales_engine.items
    @merchants = sales_engine.merchants
    @invoices = sales_engine.invoices
    @invoice_items = sales_engine.invoice_items
    @customers = sales_engine.customers
    @transactions = sales_engine.transactions
  end

  def total_merchants
    merchants.all.count
  end

  def average_items_per_merchant
    average(items.all.count, total_merchants)
  end

  def average_invoices_per_merchant
    average(invoices.all.count, total_merchants)
  end

  def collect_items_per_merchant
    merchants.all.map do |merchant|
      merchant.items.count
    end
  end

  def average_items_per_merchant_standard_deviation
    standard_deviation(collect_items_per_merchant)
  end

  def collect_invoices_per_merchant
    merchants.all.map do |merchant|
      merchant.invoices.count
    end
  end

  def average_invoices_per_merchant_standard_deviation
    standard_deviation(collect_invoices_per_merchant)
  end

  def items_given_merchant_id(merchant_id)
    merchant = sales_engine.find_merchant(merchant_id)
    merchant.items
  end

  def average_item_price_for_merchant(merchant_id)
    items = items_given_merchant_id(merchant_id)
    sum_of_prices = items.reduce(0) do |sum, item|
      sum += item.unit_price
    end
    (sum_of_prices/items.count).round(2)
  end

  def average_average_price_per_merchant
    sum_of_averages = merchants.all.reduce(0) do |total, merchant|
      total += average_item_price_for_merchant(merchant.id)
      total
    end
    (sum_of_averages / total_merchants).round(2)
  end

  def get_all_prices
    items.all.map do |item|
      item.unit_price
    end
  end

  def golden_prices
    above_standard_deviation(get_all_prices, 2)
  end

  def golden_items
    golden_prices.map do |price|
      items.find_all_by_price(price)
    end.flatten.uniq
  end

  def number_of_items_for_every_merchant
    merchants.all.map do |merchant|
      merchant.items.count
    end
  end

  def merchants_with_high_item_count
    item_count = number_of_items_for_every_merchant
    cut = mean(item_count) + standard_deviation(item_count)
    merchants.all.find_all do |merchant|
      merchant.items.count > cut
    end
  end

  def top_merchants_by_invoice_count
    invoice_count = collect_invoices_per_merchant
    cut = mean(invoice_count) + 2 * standard_deviation(invoice_count)
    merchants.all.find_all do |merchant|
      merchant.invoices.count > cut
    end
  end

  def bottom_merchants_by_invoice_count
    invoice_count = collect_invoices_per_merchant
    cut = mean(invoice_count) - 2 * standard_deviation(invoice_count)
    merchants.all.find_all do |merchant|
      merchant.invoices.count < cut
      end
  end

  def find_invoice_status
    invoices.all.each_with_object(Hash.new(0)) do |invoice,counts|
      counts[invoice.status] += 1
    end
  end

  def invoice_status(status)
    ((find_invoice_status[status].to_f/ invoices.all.count.to_f) * 100).round(2)
  end

  def invoices_per_day
    invoices.all.reduce(Array.new(7) {0}) do |days, invoice|
      days[invoice.created_at.wday] += 1
      days
    end
  end

  def top_days_by_invoice_count
    cut = mean(invoices_per_day) + standard_deviation(invoices_per_day)
    invoices_per_day.reduce([]) do |top_days, count|
      if count > cut
        top_days << days_of_week[invoices_per_day.index(count)]
      end
      top_days
    end
  end

  def total_revenue_by_date(date)
    array = invoices.all.find_all do |invoice|
      invoice.created_at == date
    end
    array.reduce(0) do |grand_total, invoice|
      grand_total += invoice.total if invoice.total
      grand_total
    end
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
    merchant = merchants.find_by_id(merchant_id)
    merchant.items.each_with_object(Hash.new(0)) do |item, item_hash|
      item_hash[item.id] = 0
    end
  end

  def get_best_items(hash)
    max = hash.values.max
    top = Hash[hash.select {|key, value| value == max}]
    top.map {|key, value| items.find_by_id(key)}
  end

  def most_sold_item_for_merchant(merchant_id)
    merchant = merchants.find_by_id(merchant_id)
    items_sold = get_merchant_items(merchant_id)
    merchant.invoices.each do |invoice|
      if invoice.is_paid_in_full?
        invoice.invoice_items.each do |invoice_item|
          items_sold[invoice_item.item_id] += invoice_item.quantity
        end
      end
    end
    get_best_items(items_sold)

  end

  def best_item_for_merchant(merchant_id)
    merchant = merchants.find_by_id(merchant_id)
    items_sold = get_merchant_items(merchant_id)
    merchant.invoices.each do |invoice|
      if invoice.is_paid_in_full?
        invoice.invoice_items.each do |invoice_item|
          items_sold[invoice_item.item_id] += invoice_item.total
        end
      end
    end
    max = items_sold.values.max
    items.find_by_id(items_sold.key(max))
  end

end
