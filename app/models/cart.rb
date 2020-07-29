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
        when "View My Sum"
            puts "Your total is #{self.sum_of_cart}"
            prompt = TTY::Prompt.new
            answer = prompt.select("Would you like to proceed to checkout?", %w(yes no))
            case answer
            when "yes"
                self.checkout
            when "no"
                self.start_cart
            end
        when "Go Back to Main Screen"
            self.user.main_screen
        when "View Items in Cart"
        end
    end



    def find_item
        prompt = TTY::Prompt.new
        puts "What would you like to search?"
        product_title = gets.chomp
        json_products = JSON.parse(RestClient.get("https://api.spoonacular.com/food/products/search?query=#{product_title}&number=5&apiKey=6bdcf4fe78474fd5a0f51e67c05b8985"))
        json_product_titles = json_products["products"].map{|i|i["title"]}
        answer = prompt.select("Which would you like to view?", json_product_titles)
        case answer
        when answer
            api_id = json_products["products"][json_product_titles.index(answer)]["id"]
            product = JSON.parse(RestClient.get("https://api.spoonacular.com/food/products/#{api_id}?apiKey=6bdcf4fe78474fd5a0f51e67c05b8985"))
            puts "Name: #{product["title"]}, price: #{product["price"]}, calories: #{product["nutrition"]["calories"]}."
            # found_product = json_products["products"].select{|i| i.title == answer}
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
            prompt = TTY::Prompt.new
            choices = ["Search Another Item", "Go Back to My Items", "Go Back to Shopping", "Return to Main Screen"]
            answer = prompt.select("What would you like to do?", choices)
            case answer
            when "Search Another Item"
                self.find_item
            when "Go Back to My Items"
                self.start_cart
            when "Go Back to Shopping"
                self.start_cart
            when "Return to Main Screen"
            end
        end
    
    end

    def sum_of_cart
        self.products.sum{|i| i.quantity * i.price}
    end

    def move_items_to_fridge
        self.products.map do |i|
            i.quantity = 0
            i.cart_id = nil
            i.fridge_id = self.user.fridge.id
            i.save
        end
    end

    def checkout
        if self.user.cards == []
            self.user.new_card
        else
            prompt = TTY::Prompt.new
            puts "The cards saved in this account is(are) #{self.user.cards.map(&:bank_name)}."
            answer = prompt.select("Do you want to proceed?", %w(yes no))
            case answer
            when "yes"
                prompt = TTY::Prompt.new
                choices = self.user.cards.map{|i| i.bank_name}
                answer = prompt.select("Which card would you like to use?", choices)
                case answer
                when answer
                    found_card = self.user.cards[choices.index(answer)]
                    if found_card.balance >= self.sum_of_cart
                    found_card.balance -= self.sum_of_cart
                    found_card.save
                    puts "Your purchase has been completed"
                    new_transaction = Transaction.create(user_id: self.user.id, cart_id: self.id, title: self.products.map(&:title), date: Time.now)                    
                    self.move_items_to_fridge
                    binding.pry
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
            when "no"
                prompt = TTY::Prompt.new
                choices = ["Update Card Information", "Delete All Items In Cart", "Go Back"]
                answer = prompt.select("What would you like to do?", choices)
                # when "Update Card Information"
                #     prompt = TTY::Prompt.new
                #     choices = ["Card Number", "Expiration Date", "CVV", "Add New Card"]
                #     answer = prompt.select("Which card would you like to update?", choices)
                #     case answer
                #     when "Card Number"
                        
                    # when "Expiration Date"
                    # when "CVV"
                    # when "Add New Card"
                    #     self.user.new_card
                    # end
                # when "Delete All Items In Cart"
                # when "Go Back"
                #     self.start_cart
                # end
                
                ## Purchase Successful
                ## Empty cart and move it to fridge
                ## also move to previous purchase

            end
        end
    end

end