require 'tty-prompt'


class Cart < ActiveRecord::Base
    belongs_to :user
    has_many :products
    has_many :transactions
    
    
    def start_cart
        prompt = TTY::Prompt.new
        choices = ["Find an Item", "View Items in Cart", "View My Sum", "Go Back to Main Screen"]
        answer = prompt.select("What would you like to do?", choices)
        case answer
        when "Find an Item"
            self.find_item
        when "View Items in Cart"
            self.products.reload
            if self.products == []
                puts "Your cart is empty!"
            else
                prompt = TTY::Prompt.new
                choices = self.products.map(&:title)
                answer = prompt.select("Your item(s) is(are):", self.products.map(&:title))
                case answer
                when answer
                    found_product = self.products[choices.index(answer)]
                    puts "You have #{found_product.quantity} of #{found_product.title}. This item has #{found_product.calories} calories, $#{found_product.price}"
                    prompt = TTY::Prompt.new
                    answer = prompt.select("Would you like to remove this item?", %w(yes no))
                    case answer
                    when "yes"
                        prompt = TTY::Prompt.new
                        remove_quantity = prompt.slider("Quantity?", max: found_product.quantity, step: 1)
                        found_product.quantity -= remove_quantity
                        found_product.save
                        if found_product.quantity == 0
                            found_product.destroy
                        end
                    puts "Item has been removed"
                    self.start_cart
                    end
                end
            end
            self.start_cart
        when "View My Sum"
            self.products.reload
            if self.products == [] || self.products == nil
                puts "Your cart is empty!"
                self.start_cart
            else
                puts "Your total is #{self.sum_of_cart}"
                prompt = TTY::Prompt.new
                answer = prompt.select("Would you like to proceed to checkout?", %w(yes no))
                case answer
                when "yes"
                    self.checkout
                when "no"
                    self.start_cart
                end
            end
        when "Go Back to Main Screen"
            self.user.main_screen
        end
    end
        
    def find_item
        prompt = TTY::Prompt.new
        puts "What would you like to search?"
        product_title = gets.chomp
        api_key = ENV["SPOON_API_KEY"]
        while product_title == "" 
            puts "You must search something!"
            product_title = gets.chomp
        end
        json_products = JSON.parse(RestClient.get("https://api.spoonacular.com/food/products/search?query=#{product_title}&number=5&apiKey=#{api_key}"))
        json_product_titles = json_products["products"].map{|i|i["title"]}
        answer = prompt.select("Which would you like to view?", json_product_titles)
        case answer
        when answer
            api_id = json_products["products"][json_product_titles.index(answer)]["id"]
            product = JSON.parse(RestClient.get("https://api.spoonacular.com/food/products/#{api_id}?apiKey=#{api_key}"))
            puts "Name: #{product["title"]}, price: #{product["price"]}, calories: #{product["nutrition"]["calories"]}."
            prompt2 = TTY::Prompt.new
            answer = prompt2.select("Would you like to add the item to your cart?", %w(yes no))
            case answer
            when "yes"
                puts "Quantity:"
                product_quantity = gets.chomp.to_i
                var = product["title"]
                possible_product = self.products.select{|product| product.title == var}
                if possible_product == []
                    new_product = Product.create(title: product["title"], cart_id: self.id, quantity: product_quantity, price: product["price"], calories: product["nutrition"]["calories"])
                else
                    possible_product[0].quantity += product_quantity
                    possible_product[0].save
                end
            when "no"
            end
        end
        prompt = TTY::Prompt.new
        choices = ["Search Another Item", "Go Back to My Items", "Go Back to Shopping"]
        answer = prompt.select("What would you like to do?", choices)
        case answer
        when "Search Another Item"
            self.find_item
        when "Go Back to My Items"
            self.start_cart
        when "Go Back to Shopping"
            self.start_cart
        end
    end

    def sum_of_cart
        self.products.sum{|i| i.quantity * i.price}
    end

    def move_items_to_fridge
        self.products.map do |i|
            i.cart_id = nil
            i.fridge_id = self.user.fridge.id
            i.save
        end
    end

    def checkout
        self.user.cards.reload
        if self.user.cards == [] || self.user.cards == nil
            self.user.new_card
            self.checkout
        else
            prompt = TTY::Prompt.new
            self.user.cards.reload
            puts "The card(s) saved in this account is(are) #{self.user.cards.map(&:bank_name)}."
            answer = prompt.select("Do you want to proceed?", %w(yes no))
            case answer
            when "yes"
                prompt = TTY::Prompt.new
                choices = self.user.cards.map{|i| i.bank_name}
                answer = prompt.select("Which card would you like to use?", choices)
                case answer
                when answer
                    found_card = self.user.cards[choices.index(answer)]
                    binding.pry
                    if found_card.balance >= self.sum_of_cart
                    found_card.balance -= self.sum_of_cart
                    found_card.save
                    puts "Your purchase has been completed"
                    new_transaction = Transaction.create(user_id: self.user.id, cart_id: self.id, title: self.products.map(&:title), date: Time.now, total: self.products.sum(&:price))                    
                    self.move_items_to_fridge
                    self.products.reload
                    save
                    self.start_cart
                    # puts "Would you like to see possible recipes?"
                    else
                        answer = prompt.select("Transaction failed. Would you like to select another card?", %w(yes no))
                        case answer
                        when "yes"
                            self.checkout
                        when "no"
                            self.start_cart
                        end
                    end
                end
            end
        end
    end

end