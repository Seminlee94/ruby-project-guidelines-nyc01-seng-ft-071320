#TODO
### Add cart to Previous Purchase
### Refactor
### Add recipes
### Update Card Information
### View Previous Purchases






class User < ActiveRecord::Base
    has_one :fridge
    has_one :cart
    has_many :cards
    has_many :transactions
    
    def self.login
        choices = [ "Create a New Account", "Log into My Account"]
        prompt = TTY::Prompt.new
        answer = prompt.select("Hello! Welcome to Cart-In, What would you like to do?", choices)
        case answer
        when "Create a New Account"
            puts "Welcome to Cart-In. To begin, please follow the instructions." 
            new_id
        when "Log into My Account"
            return_user
        end
    end
    
    def self.return_user
        puts "What is your log-in ID?"
        find_id = gets.chomp
        puts "What is your log-in password?"
        find_pass = gets.chomp
        if self.find_by(log_in_id: find_id, log_in_pass: find_pass) == nil
            puts "That is a invalid Id and Password. Please try again"
            return_user
        else 
            r_user = self.find_by(log_in_id: find_id, log_in_pass: find_pass)
            r_user.main_screen
        end
    end

    def self.new_id
        puts "Enter a log-in ID."
        username = gets.chomp
        if self.find_by(log_in_id: username) == nil
            puts "Please enter a password"
            password = gets.chomp
            new_user = User.create(log_in_id: username, log_in_pass: password)
            Cart.create(user_id: new_user.id)
            Fridge.create(user_id: new_user.id)
            prompt = TTY::Prompt.new
            answer = prompt.select("Would you like to start shopping?", %w(yes no))
            case answer
            when "yes"
                new_user.cart.start_cart
            when "no"
                new_user.main_screen
            end
        else 
            puts "That log-in ID is not available. Please try another."
            self.new_id
        end
    end

    def main_screen
        prompt = TTY::Prompt.new
        choices = ["View My Profile", "View My Fridge", "Start Shopping", "Exit App"]
        answer = prompt.select("What would you like to do?", choices)
        case answer
        when "View My Profile"
            self.user_profile 
        when "View My Fridge"
            self.fridge.my_fridge
        when "Start Shopping"
            self.cart.start_cart
        when "Exit App"
            exit!
        end

    end 

    def user_profile
        prompt = TTY::Prompt.new
        choices = [ "View My Info", "View My Payment Methods", "View My Previous Transaction", "View MY Previous Recipe", "Go Back to Main Screen"]
        answer = prompt.select("What would you like to do?", choices)
        case answer
        when "View My Info"
            if self.name == nil || self.address == nil
                puts "We need your info"
                prompt = TTY::Prompt.new
                answer = prompt.select("Would you like to change name or address?", %w(name address))
                case answer
                when "name"
                    self.name = gets.chomp
                when "address"
                    self.address = gets.chomp
                end
                puts "Name: #{self.name}"
                puts "Address: #{self.address}"
                self.user_profile
            else
                puts "Name: #{self.name}"
                puts "Address: #{self.address}"#cart
                self.user_profile
            end
        when "View My Payment Methods" # will need a class variable if we want to store different payment methods...User has many credit_cards
            if self.cards == []
                self.new_card
            else
                prompt = TTY::Prompt.new
                puts "The cards saved in this account is(are) #{self.cards.map(&:card_number)}."
                answer = prompt.select("Is this correct?", %w(yes no))
                case answer
                when "yes"
                    self.user_profile
                when "no"
                    choices = ["Card Number", "Expiration Date", "CVV", "Add New Card"]
                    answer = prompt.select("Which information would you like to update?", choices)
                    case answer
                    when "Card Number"
                    when "Expiration Date"
                    when "CVV"
                        puts "CVV:"
                        cvv_number = gets.chomp.to_i
                    when "Add New Card"
                        self.new_card
                    end
                end
            end
        when "View My Previous Transaction"
            prompt = TTY::Prompt.new
            choices = self.transactions.map(&:date)
            answer = prompt.select("Which transaction would you like to view?", choices)
            case answer
            when answer
                found_transaction = self.transactions[choices.index(answer)]
                puts "#{found_transaction.title} item(s) were purchased on this day. The total was #{found_transaction.cart.products.sum(&:price)}"
                binding.pry
                self.user_profile
            end
        # when "View My Previous Recipe" #same here but for the recipe array
        when "Go Back to Main Screen"
            self.main_screen
        end
    end

    def new_card
        puts "Please enter your card information"
        puts "Card Number: "
        number = gets.chomp.to_i
        puts "Expiration Date: (MMYYYY)"
        date = gets.chomp.to_i
        puts "CVV:"
        cvv_number = gets.chomp.to_i
        new_card = Card.create(user_id: self.id, name: self.name, card_number: number, expiration_date: date, CVV: cvv_number)
    end

end

