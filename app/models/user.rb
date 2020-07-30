#TODO
### Refactor
### When person enters wrong ID/pass, can choose to make new
### Press ANY KEY to continue
### check for bugs
### remove ingredients with tbsp measurements, etc.
### Show Missing Ingredients, would you like to buy? (buy qty. 1 of everything needed)
### 

class User < ActiveRecord::Base
    has_one :fridge
    has_one :cart
    has_many :cards
    has_many :transactions
    
    def self.login
        choices = [ "Create a New Account", "Log into My Account"]
        prompt = TTY::Prompt.new
        answer = prompt.select("Hello! Welcome to ShopNCook, What would you like to do?", choices)
        case answer
        when "Create a New Account"
            puts "To begin, please follow the instructions." 
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
            puts "Please enter your name"
            make_name = gets.chomp
            puts "Please enter your address"
            make_address = gets.chomp
            new_user = User.create(log_in_id: username, log_in_pass: password, name: make_name, address: make_address)
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
            puts "Thank you for using ShopNCook. Hope to see you again!"
            exit!
        end

    end 

    def user_profile
        prompt = TTY::Prompt.new
        choices = [ "View My Info", "View My Payment Methods", "View My Previous Transaction", "View MY Previous Recipe", "Go Back to Main Screen"]
        answer = prompt.select("What would you like to do?", choices)
        case answer
        when "View My Info"
            puts "Log-in ID: #{self.log_in_id}, Password: #{self.log_in_pass}"
            puts "Name: #{self.name}, and address: #{self.address}"
            prompt = TTY::Prompt.new
            answer = prompt.select("Would you like to update your profile?", %w(name address password exit))
            case answer
            when "name"
                self.name = gets.chomp
            when "address"
                self.address = gets.chomp
            when "password"
                prompt = TTY::Prompt.new
                password = prompt.mask("password")
                self.log_in_pass = password
            when "exit"
                self.user_profile
            end
            puts "Name: #{self.name}"
            puts "Address: #{self.address}"
            self.user_profile
        when "View My Payment Methods"
            if self.cards == []
                self.new_card
            else
                prompt = TTY::Prompt.new
                puts "The card(s) saved in this account is(are) #{self.cards.map(&:bank_name)}."
                choices = ["Add New Card", "Delete a Card", "Go Back"]
                answer = prompt.select("Would you like to add a new card?", %w(yes no))
                case answer
                when "Add New Card"
                    self.new_card
                    self.user_profile
                when "Delete a Card"
                    self.delete_card
                    self.user_profile
                when "Go Back"
                    self.user_profile
                end
            end
        when "View My Previous Transaction"
            self.transactions.reload
            prompt = TTY::Prompt.new
            choices = self.transactions.map(&:date)
            answer = prompt.select("Which transaction would you like to view?", choices)
            case answer
            when answer
                self.transactions.reload
                found_transaction = self.transactions[choices.index(answer)]
                puts "#{found_transaction.title} item(s) were purchased on this day. The total was #{self.transactions[choices.index(answer)].total}"
                # binding.pry
                self.user_profile
            end
        when "View My Previous Recipe" #same here but for the recipe array
            self.fridge.products
        when "Go Back to Main Screen"
            self.main_screen
        end
    end


    def new_card
        puts "Please enter your card information"
        puts "Name of Bank:"
        name_of_bank = gets.chomp.to_s
        puts "Card Number: "
        number = gets.chomp.to_i
        puts "Expiration Date: (MMYYYY)"
        date = gets.chomp.to_i
        puts "CVV:"
        cvv_number = gets.chomp.to_i
        new_card = Card.create(bank_name: name_of_bank, user_id: self.id, name: self.name, card_number: number, expiration_date: date, CVV: cvv_number, balance: 20000000)
    end

    def delete_card
        prompt = TTY::Prompt.new
        choices = self.cards.map{|i| i.bank_name}
        answer = prompt.select("Which card would you like to use?", choices)
        case answer
        when answer
            found_card = self.cards[choices.index(answer)]
            found_card.destroy
        end
    end
    
end

