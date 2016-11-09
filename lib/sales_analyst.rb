require_relative 'sales_engine'
require_relative 'sa_assistant'
require_relative 'merchant_analyst'

class SalesAnalyst
  include SAAssistant
  attr_reader   :sales_engine,
                :merchant_analyst,
                :items,
                :merchants,
                :invoices,
                :invoice_items,
                :customers,
                :transactions


  def initialize(sales_engine)
    @sales_engine = sales_engine
    @merchant_analyst = MerchantAnalyst.new(self)
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

  def collect_invoices
    merchants.all.map do |merchant|
      merchant.invoices.count
    end
  end

  def average_invoices_per_merchant_standard_deviation
    standard_deviation(collect_invoices)
  end

  def items_given_merchant_id(merchant_id)
    find_merchant(merchant_id).items
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
    cut = mean(collect_invoices) + 2 * standard_deviation(collect_invoices)
    merchants.all.find_all do |merchant|
      merchant.invoices.count > cut
    end
  end

  def bottom_merchants_by_invoice_count
    cut = mean(collect_invoices) - 2 * standard_deviation(collect_invoices)
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
    merchant_analyst.merchants_with_only_one_item
  end

  def revenue_by_merchant(merchant_id)
    merchant_analyst.revenue_by_merchant(merchant_id)
  end

  def merchants_ranked_by_revenue
    merchant_analyst.merchants_ranked_by_revenue
  end

  def top_revenue_earners(number = 20)
    merchant_analyst.top_revenue_earners(number)
  end

  def merchants_with_pending_invoices
    merchant_analyst.merchants_with_pending_invoices
  end

  def merchants_with_only_one_item_registered_in_month(month)
    merchant_analyst.merchants_with_only_one_item_registered_in_month(month)
  end

  def get_merchant_items(merchant_id)
    merchant_analyst(merchant_id)
  end

  def find_merchant(merchant_id)
    merchants.find_by_id(merchant_id)
  end

  def get_best_items(hash)
    merchant_analyst.get_best_items(hash)
  end

  def check_invoice_quantity(items, invoice)
    merchant_analyst.check_invoice_quantity(items, invoice)
  end

  def check_invoice_total(items, invoice)
    merchant_analyst.check_invoice_total
  end

  def most_sold_item_for_merchant(merchant_id)
    merchant_analyst.most_sold_item_for_merchant(merchant_id)
  end

  def best_item_for_merchant(merchant_id)
    merchant_analyst.best_item_for_merchant(merchant_id)
  end

end
