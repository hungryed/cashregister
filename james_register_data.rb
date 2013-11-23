require './james_refactored_file.rb'
require './james_data_realm.rb'
require 'csv'
require 'pry'
require 'json'

class DataRegistry

  def initialize
    initial_decision
  end

  def clear_screen
    puts "\e[H\e[2J"
  end

  def initial_decision
    clear_screen
    puts "Welcome to James' coffee empire"
    puts
    puts "1) Make a transaction."
    puts "2) Enter the data realm."
    puts "3) Exit"
    input = questioner("What would you like to do?: ")
    if input == "1"
      clear_screen
      run_the_register
    elsif input == "2"
      enter_the_data_realm
    elsif input == "3"
      exit
    else
      puts "Please enter a valid input"
      initial_decision
    end
  end

  def questioner(question)
    print question
    input = gets.chomp
  end

  def run_the_register
    james = Register.new
    customer_transaction = james.customer_transaction
    data = transform_file_data(customer_transaction)
    write_to_file(data)
    sleep(8)
    initial_decision
  end

  def enter_the_data_realm
    manager = DataRealm.new
    manager.initialize
    initial_decision
  end

  def transform_file_data(new_transaction)
    list = []
    input_transaction = {}
    new_transaction.each do |key,value|
      input_transaction[key] = value
    end
    list << input_transaction
    list
  end

  def parse_file_data
    data = CSV.read('coffee_transactions.csv')
    data
  end

  def write_to_file(data_to_insert)
    CSV.open('coffee_transactions.csv', 'a+') do |writer|
      data_to_insert.each do |transaction|
        writer << transaction.values
      end
    end
  end
end

go = DataRegistry.new
go.initial_decision

