require 'pry'
require 'csv'
require 'json'

class DataRealm

  def initialize

  end

  def initial_display
    clear_screen
    puts "Welcome to the data realm."
    puts ""
    puts "1) List sales for a certain date"
    puts "2) List sales for a range of dates"
    puts "3) Check profits"
    puts "4) Check item sales for a range of dates"
    decision = questioner("What would you like to do?: ")
        reset
    decision
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

  def reset
    @item_list ={}
    make_item_list
    get_current_data
  end

  def get_current_data
    @current_sales = []
    data = CSV.foreach('coffee_transactions.csv', headers: true)
        binding.pry
    data = JSON.parse(data)

    data
  end

  def questioner(question)
    print question
    input = gets.chomp
  end

  def clear_screen
    puts "\e[H\e[2J"
  end

end

manager = DataRealm.new
manager.initial_display
