# require 'csv'
# require 'pry'

class Register

  def initialize
    @item_list = {}
    @strength_options = []
    @flavor_options = []
  end

  def make_strength_list(row)
    if @strength_options.include?(row[:item_style])
      true
    else
      @strength_options << row[:item_style]
    end
  end

  def make_flavor_list(row)
    if @flavor_options.include?(row[:item_flavor])
      true
    else
      @flavor_options << row[:item_flavor]
    end
  end

  def make_item_list
    CSV.foreach('item_list.csv', headers: true, header_converters: :symbol ) do |row|
      @item_list[[row[:item_style], row[:item_flavor]].join(" ")] = {
          sku:row[:sku],
          purchase_price:row[:purchase_price],
          retail_price:row[:retail_price]
      }
      make_flavor_list(row)
      make_strength_list(row)
    end
    @item_list
    @all_items = @item_list.keys
  end

  def subtotal(strength, flavor, amount)
    @transaction["Subtotal"] += amount.to_i * @item_list["#{strength} #{flavor}"][:purchase_price].to_f
    @transaction["Retail_price"] += amount.to_i * @item_list["#{strength} #{flavor}"][:retail_price].to_f
    puts "Subtotal: $#{format_money(@transaction["Subtotal"])}"
  end

  def final_subtotal(hash)
    puts "Your total is $#{format_money(hash["Subtotal"])}"
    hash["Subtotal"]
  end

  def reset
    @transaction = Hash.new(0)
    @transaction["Subtotal"] = 0
    @all_items.each do |name|
      @transaction[name.to_s] = 0
    end
  end

  def transform(input)
    input.gsub(/\$/, '')
  end

  def format_money(amount)
    sprintf('%0.02f', amount.to_f)
  end

  def check_input(input)
    input = input.gsub(/\$/, '')
    pattern = /\A?\d+(\.\d{1,2})?\z/

    if input !~ pattern
      puts 'WARNING: Invalid number detected!'
      false
    else
      true
    end
  end

  def question(question_string)
    print question_string
    selection = gets.chomp
  end

  def restart?
    selection = question('Would you like to do another transaction?')
    selection.downcase.include?('yes') ? customer_transaction : exit
  end

  def display_joiner(array)
    array.join("/")
  end

  def flavor_maker(strength, flavor)
    "#{flavor} #{strength}"
  end

  def get_the_flavor
    flavor = question("What flavor did you purchase?(#{display_joiner(@flavor_options)}): ")
    flavor.capitalize!
    if @flavor_options.include?(flavor)
      flavor
    else
      puts 'Please supply a valid flavor'
      get_the_flavor
    end
  end

  def get_the_strength
    robustness = question("What level of coffee did you get?(#{display_joiner(@strength_options)}): ")
    return false if robustness == "done"
    robustness.capitalize!
    if @strength_options.include?(robustness)
      robustness
    else
      puts "Please supply a valid level"
      get_the_strength
    end
  end

  def get_the_amount(strength, flavor)
    amount = question('How many did you purchase?: ')
    coffee = flavor_maker(strength, flavor)
    if check_input(amount)
      @transaction[coffee] += amount.to_i
      amount
    else
      puts "Please put in a proper amount"
      get_the_amount(strength, flavor)
    end
  end

  def final_payment_checker(amount, customer_payment)
    if amount.to_f > 0 || amount.to_f == 0
      puts "    ===Thank You!=== \n
  The total change due is $#{format_money(amount)} \n \n
  #{Time.now.strftime("%m/%d/%Y   %l:%M")}\n
  ================"
      customer_payment
    else
      puts "WARNING: Customer still owes $#{format_money(amount.abs)}!"
      payment_transaction(amount)
    end
  end

  def initial_display
    puts "Welcome to James' coffee emporium!"
    puts ''
  end

  def payment_transaction(amount_due)
    customer_payment = question("What is the amount tendered?: ")
    if customer_payment.split(".")[1].length > 2
      puts "Please enter a valid amount"
      payment_transaction(amount_due)
    else
      difference = (customer_payment.to_f - amount_due.to_f)
      final_customer_payment = final_payment_checker(difference, customer_payment)
      @transaction["date_of_transaction"] = Time.now
      @transaction["customer_payment"] = final_customer_payment
    end
  end

  def customer_transaction
    initial_display
    make_item_list
    reset
    while true
      strength = get_the_strength
      break if strength == false
      flavor = get_the_flavor
      amount = get_the_amount(flavor, strength)
      puts subtotal(strength, flavor, amount)
    end
    amount_due = final_subtotal(@transaction)
    payment_transaction(amount_due)
    @transaction
  end
end

# james = Register.new
# james.customer_transaction
