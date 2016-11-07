require_relative 'sales_engine'
require_relative 'standard_deviation'
require 'pry'

class SalesAnalyst
  include StandardDeviation
  attr_reader   :sales_engine

  def initialize(sales_engine)
    @sales_engine = sales_engine
  end

  def total_items
    sales_engine.items.all.count
  end

  def total_merchants
    sales_engine.merchants.all.count
  end

  def total_invoices
    sales_engine.invoices.all.count
  end

  def average_items_per_merchant
    average(total_items, total_merchants)
  end

  def average_invoices_per_merchant
    average(total_invoices, total_merchants)
  end

  def collect_items_per_merchant
    sales_engine.merchants.all.map do |merchant|
      merchant.items.length
    end
  end

  def average_items_per_merchant_standard_deviation
    standard_deviation(collect_items_per_merchant)
  end

  def collect_invoices_per_merchant
    sales_engine.merchants.all.map do |merchant|
      merchant.invoices.length
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
    average(sum_of_prices, items.count)
  end

  def average_average_price_per_merchant
    all_merchants = sales_engine.merchants.all
    sum_of_averages = all_merchants.reduce(0) do |total, merchant|
      total += average_item_price_for_merchant(merchant.id)
      total
    end
    (sum_of_averages / total_merchants).round(2)
  end

  def get_all_prices
    sales_engine.items.all.map do |item|
      item.unit_price
    end
  end

  def golden_prices
    above_standard_deviation(get_all_prices, 2)
  end

  def golden_items
    items = golden_prices.map do |price|
      sales_engine.items.find_all_by_price(price)
    end
    items.flatten.uniq
  end

  def number_of_items_for_every_merchant
    sales_engine.merchants.all.map do |merchant|
      merchant.items.length
    end
  end

  def merchants_with_high_item_count
    item_count = number_of_items_for_every_merchant
    cut = mean(item_count) + standard_deviation(item_count)
    sales_engine.merchants.all.find_all do |merchant|
      merchant.items.count > cut
    end
  end

  def top_merchants_by_invoice_count
    invoice_count = collect_invoices_per_merchant
    cut = mean(invoice_count) + 2 * standard_deviation(invoice_count)
    sales_engine.merchants.all.find_all do |merchant|
      merchant.invoices.count > cut
    end
  end

  def bottom_merchants_by_invoice_count
    invoice_count = collect_invoices_per_merchant
    cut = mean(invoice_count) - 2 * standard_deviation(invoice_count)
    sales_engine.merchants.all.find_all do |merchant|
      merchant.invoices.count < cut
      end
  end

  def find_invoice_status
    sales_engine.invoices.all.each_with_object(Hash.new(0)) do |invoice,counts|
    counts[invoice.status] += 1
    end
  end

  def invoice_status(status)
    ((find_invoice_status[status].to_f/ total_invoices.to_f) * 100).round(2)
  end

  def days_of_week
    { 0 => "Sunday",
      1 => "Monday",
      2 => "Tuesday",
      3 => "Wednesday",
      4 => "Thursday",
      5 => "Friday",
      6 => "Saturday",
    }
  end

  def invoices_per_day
    sales_engine.invoices.all.reduce(Array.new(7) {0}) do |days, invoice|
      days[invoice.created_at.wday] += 1
      days
    end
  end

  def average_number_of_invoices_per_day
    (invoices_per_day.reduce(:+) / 7.to_f).round(2)
  end

  def top_days_by_invoice_count
    cut = average_number_of_invoices_per_day + standard_deviation(invoices_per_day)
    invoices_per_day.reduce([]) do |top_days, day|
      if day > cut
        top_days << days_of_week[invoices_per_day.index(day)]
      end
      top_days
    end
  end

  def total_revenue_by_date(date)
    array = sales_engine.invoices.all.find_all do |invoice|
      invoice.created_at == date
    end
    array.reduce(0) do |grand_total, invoice|
      grand_total += invoice.total if invoice.total
      grand_total
    end
  end

  def merchants_with_only_one_item
    sales_engine.merchants.all.find_all do |merchant|
      merchant.items.length == 1
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
    revenue_earners = sales_engine.merchants.all.sort_by do |merchant|
      revenue_by_merchant(merchant.id)
    end
    revenue_earners.reverse.uniq
  end

  def top_revenue_earners(number = 20)
    merchants_ranked_by_revenue[0..number-1]
  end

  def merchants_with_pending_invoices
    array = []
    sales_engine.merchants.all.each do |merchant|
      merchant.invoices.each do |invoice|
      array << merchant if invoice.is_paid_in_full? == false
      end
    end
    array.uniq
  end

  def merchants_with_only_one_item_registered_in_month(month)
    find_month = sales_engine.merchants.all.find_all do |merchant|
      merchant.created_at.month == Time.parse(month).month
    end
    find_month.find_all do |merchant|
      merchant.items.count == 1
    end
  end

  def most_sold_item_for_merchant(merchant_id)
    merchant = sales_engine.merchants.find_by_id(merchant_id)
    items_sold = Hash.new(0)
    merchant.items.each do |item|
      items_sold[item.id] = 0
    end
    merchant.invoices.each do |invoice|
      if invoice.is_paid_in_full?
        invoice.invoice_items.each do |invoice_item|
          items_sold[invoice_item.item_id] += invoice_item.quantity
        end
      end
    end
    max = items_sold.values.max
    top_items_sold = Hash[items_sold.select {|key, value| value == max}]
    top_items_sold.map do |key, value|
      sales_engine.items.find_by_id(key)
    end
  end

    def best_item_for_merchant(merchant_id)
    merchant = sales_engine.merchants.find_by_id(merchant_id)
    items_sold = Hash.new(0)
    merchant.items.each do |item|
      items_sold[item.id] = 0
    end
    merchant.invoices.each do |invoice|
      if invoice.is_paid_in_full?
        invoice.invoice_items.each do |invoice_item|
          items_sold[invoice_item.item_id] += (invoice_item.quantity * invoice_item.unit_price)
        end
      end
    end
    max = items_sold.values.max
    item_id = items_sold.key(max)
    sales_engine.items.find_by_id(item_id)
  end

end
