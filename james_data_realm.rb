# require 'pry'
# require 'csv'
# require 'json'

class DataRealm

  def initialize

  end

  def initial_display
    clear_screen
    puts "Welcome to the data realm."
    puts ""
    puts "1) List sales for a certain date"
    puts "2) List sales for a range of dates"
    puts "3) Check item sales for a range of dates"
    decision = questioner("What would you like to do?: ")
    reset
    course_of_action(decision.to_i)
  end

  def make_item_list
    CSV.foreach('item_list.csv', headers: true, header_converters: :symbol ) do |row|
    @item_list[[row[:item_style], row[:item_flavor]].join(" ")] = {
        sku:row[:sku],
        purchase_price:row[:purchase_price],
        retail_price:row[:retail_price]
    }
    end
  end

  def format_money(amount)
    sprintf('%0.02f', amount.to_f)
  end

  def data_without_certain_ele(array, arg1=nil, arg2=nil, arg3=nil, arg4=nil)
    elements_to_ignore = [arg1.to_sym, arg2.to_sym, arg3.to_sym, arg4.to_sym]
    array_to_table = []
    array.each do |transaction|
      hash_to_table = Hash.new(0)
      transaction.each do |key, value|
        total_items = []
        if elements_to_ignore.include?(key.to_sym)
          hash_to_table[key] = value
          next
        else
          total_items << value.to_i
        end
        hash_to_table["Total items"] += total_items.inject(:+)
      end
      array_to_table << hash_to_table
    end
    array_to_table
  end

  def data_extract(array, argument)
    array_for_output = []
    array.each do |transaction|
      array_for_output << transaction[argument.to_sym].to_f
    end
    array_for_output
  end

  def specific_date_sales(array)
    total = data_extract(array, "subtotal")
    retail_total = data_extract(array, "retail_price")
    total = total.inject(:+)
    retail_total = retail_total.inject(:+)
    profits = total - retail_total
    puts "Gross sales for the day: $#{format_money(total)}"
    puts "Net profit for the day: $#{format_money(profits)}"
  end

  def sales_getter(arg1, arg2)
    @all_current_sales.find_all do |hash|
      tran_time = Date.parse(hash[:date_of_transaction]).to_time
      tran_time.between?(arg1.to_time, arg2.to_time)
    end
  end

  def specific_sale_date
    desired_date = date_getter("What date would you like to see?: ")
    all_sales_on_date = sales_getter(desired_date.to_time, desired_date.to_time + 86400)
    if all_sales_on_date.length >= 1
      tp data_without_certain_ele(all_sales_on_date, "subtotal", "retail_price", "date_of_transaction", "customer_payment")
      specific_date_sales(all_sales_on_date)
    else
      puts "Not found"
    end
  end

  def ranged_sale_date
    start_date = date_getter("What date do you wish to start at?: ")
    end_date = range_date_getter("What date do you wish to end at?: ")
    if end_date.to_time < start_date.to_time
      puts "Please enter a future date"
      ranged_sale_date
    else
      sales_between = sales_getter(start_date, end_date)
      if sales_between.length >= 1
        tp data_without_certain_ele(sales_between, "subtotal", "retail_price", "date_of_transaction", "customer_payment")
        specific_date_sales(sales_between)
        range_total_profit(sales_between)
      else
        puts "Not found"
      end
    end
  end

  def range_string_maker(array1, array2, array3)
    subtotal = array1.inject(:+)
    retail_total = array2.inject(:+)
    item_total = array3.inject(:+)
    array_of_inputs = [subtotal, retail_total, item_total]
    array_of_inputs.each do |array|
      if array == nil
        array = 0
      else
        next
      end
    end
    puts "Total sales over span: $#{subtotal}"
    puts "Total profit: $#{subtotal - retail_total}"
    puts "Total items sold: #{item_total}"
  end

  def range_total_profit(array)
    elements_to_ignore = ["subtotal".to_sym,
      "retail_price".to_sym,
      "date_of_transaction".to_sym,
      "customer_payment".to_sym
     ]
    range_subtotal = []
    range_retail_price = []
    range_item_total = []
    array.each do |transaction|
      transaction.each do |key, value|
        range_subtotal << transaction[key].to_i if key == :subtotal
        range_retail_price << transaction[key].to_i if key == :retail_price
        if elements_to_ignore.include?(key)
          next
        else
          range_item_total << value.to_i
        end
      end
    end
    range_string_maker(range_subtotal, range_retail_price, range_item_total)
  end

  def range_date_getter(question_to_ask)
    puts "Please put date in month-day-year format"
    date = questioner(question_to_ask)
    date << " 05:00:00"
    date = DateTime.strptime(date, "%m-%d-%Y %H:%M:%S") rescue nil
    if date != nil
      if date.to_time > Time.now
        date = Time.now
      else
        return date
      end
    else
      puts "Please enter a valid date format"
      date_getter(question_to_ask)
    end
  end

  def date_getter(question_to_ask)
    puts "Please put date in month-day-year format"
    date = questioner(question_to_ask)
    date << " 05:00:00"
    date = DateTime.strptime(date, "%m-%d-%Y %H:%M:%S") rescue nil
    if date != nil
      if date.to_time > Time.now
        puts "That date is in the future"
        date_getter(question_to_ask)
      else
        return date
      end
    else
      puts "Please enter a valid date format"
      date_getter(question_to_ask)
    end
  end

  def specific_product_hash_item_maker(array)
    items = {}
    items["Light Vanilla"] = data_extract(array, "light_vanilla")
    items["Medium Vanilla"] = data_extract(array, "medium_vanilla")
    items["Bold Vanilla"] = data_extract(array, "bold_vanilla")
    items["Light Hazelnut"] = data_extract(array, "light_hazelnut")
    items["Medium Hazelnut"] = data_extract(array, "medium_hazelnut")
    items["Bold Hazelnut"] = data_extract(array, "bold_hazelnut")
    output = {}
    items.each do |key,value|
      output[key] = value.inject(:+).to_i
    end
    output
  end

  def specific_product_value
    start_date = date_getter("What date do you wish to start at?: ")
    end_date = range_date_getter("What date do you wish to end at?: ")
    if end_date.to_time < start_date.to_time
      puts "Please enter a future date"
      specific_product_value
    else
      all_sales_on_date = sales_getter(start_date, end_date)
      output = {}
      item_total_output = specific_product_hash_item_maker(all_sales_on_date)
      item_total_output.each do |key, value|
        output[key] = {:"total_sold" => value,
          :"gross_sales" => (@item_list[key][:purchase_price].to_i*value.to_i),
          :"net_profit" => (@item_list[key][:purchase_price].to_i*value.to_i - @item_list[key][:retail_price].to_i*value.to_i)
        }
      end
      output.each do |key,value|
        # puts "#{key}: "
        # value.each do |key, value|
        #   print "\t #{key}: "
        #   if value != :"total_sold"
        #     puts "#{value}"
        #   else
        #     puts "$#{value}"
        #   end
        # end
        # puts "-----------"
        puts "#{key}:"
        tp value
        puts "---------------------------"
        puts
        puts
      end
      range_total_profit(all_sales_on_date)
    end
  end

  def course_of_action(input)
    if input == 1
      specific_sale_date
    elsif input == 2
      ranged_sale_date
    elsif input == 3
      specific_product_value
    else
      puts "Please enter a valid request"
      sleep(3)
      initial_display
    end
  end

  def reset
    @item_list ={}
    make_item_list
    get_current_data
  end

  def get_current_data
    @all_current_sales = []
    CSV.foreach('coffee_transactions.csv', headers: true, header_converters: :symbol) do |sale|
      current_sale = {}
      sale.each do |key,value|
        current_sale[key] = value
      end
      @all_current_sales << current_sale
    end
  end

  def questioner(question)
    print question
    input = gets.chomp
  end

  def clear_screen
    puts "\e[H\e[2J"
  end

end

# manager = DataRealm.new
# manager.initial_display
