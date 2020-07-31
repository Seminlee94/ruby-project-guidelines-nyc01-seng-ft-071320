#TODO
### Refactor
### check for bugs
### remove ingredients with tbsp measurements, etc. (future improvements)

class User < ActiveRecord::Base
    has_one :fridge
    has_one :cart
    has_many :cards
    has_many :transactions
    
    def self.login
        choices = [ "Create a New Account", "Log into My Account"]
        prompt = TTY::Prompt.new
        answer = prompt.select("What would you like to do?", choices)
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
            prompt = TTY::Prompt.new
            choices = [ "Forgot Log-in ID", "Forgot Password", "Try Again"]
            answer = prompt.select("That is a invalid Id and Password. Please try again", choices)
            case answer
            when "Forgot Log-in ID"
                puts "Enter your name:"
                find_name = gets.chomp
                puts "Enter your address:"
                find_address = gets.chomp
                find_user = self.find_by(name: find_name, address: find_address)
                if find_user
                    puts "Your username is #{find_user.log_in_id}."
                    prompt.keypress("Press enter to continue", keys: [:return])
                    return_user
                else 
                    answer = prompt.select("That user does not exist. Would you like to make a new one?", %w(yes no))
                    case answer
                    when "yes"
                        new_id
                    when "no"
                        return_user
                    end
                end
            when "Forgot Password"
                puts "Enter your Log-in ID:"
                find_id = gets.chomp
                puts "Enter your name:"
                find_name = gets.chomp
                puts "Enter your address:"
                find_address = gets.chomp
                find_user = self.find_by(log_in_id: find_id, name: find_name, address: find_address)
                if find_user
                    puts "Your username is #{find_user.log_in_id}, please enter a new password:"
                    find_user.log_in_pass = gets.chomp
                    puts "New password set. Returning to login page."
                    prompt.keypress("Press enter to continue", keys: [:return])
                    return_user
                else 
                    puts "The information you have entered it not correct. Please try again."
                    return_user
                end
            when "Try Again"
                return_user
            end
        else 
            r_user = self.find_by(log_in_id: find_id, log_in_pass: find_pass)
            r_user.main_screen
        end
    end

    def self.new_id
        prompt = TTY::Prompt.new
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
            answer = prompt.select("Would you like to start shopping?", %w(yes no))
            case answer
            when "yes"
                new_user.cart.start_cart
            when "no"
                new_user.main_screen
            end
        else
            prompt.keypress("That log-in ID is not available. Please try another. Press enter to continue", keys: [:return])
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
        choices = ["View My Info", "View My Payment Methods", "View My Previous Transaction","Go Back to Main Screen"]
        answer = prompt.select("What would you like to do?", choices)
        case answer
        when "View My Info"
            puts "Log-in ID: #{self.log_in_id}, Password: #{self.log_in_pass}"
            puts "Name: #{self.name}, and address: #{self.address}"
            prompt = TTY::Prompt.new
            choices = ["Name", "Address", "Password", "Exit"]
            answer = prompt.select("Would you like to update your profile?", choices)
            case answer
            when "Name"
                puts "Name:"
                self.name = gets.chomp
            when "Address"
                puts "Address:"
                self.address = gets.chomp

            when "Password"
                prompt = TTY::Prompt.new
                password = prompt.mask("Password")
                self.log_in_pass = password
            when "Exit"
                user_profile
            end
            self.save
            puts "Name: #{self.name}"
            puts "Address: #{self.address}"
            prompt.keypress("Press enter to continue", keys: [:return])
            user_profile
        when "View My Payment Methods"
            self.cards.reload
            if self.cards == []
                Card.new_card(self.id, self.name)
            else
                prompt = TTY::Prompt.new
                puts "The card(s) saved in this account is(are) #{self.cards.map(&:bank_name)}."
                choices = ["Add New Card", "Delete a Card", "Go Back"]
                answer = prompt.select("What would you like to do?", choices)
                case answer
                when "Add New Card"
                    Card.new_card(self.id, self.name)
                when "Delete a Card"
                    self.delete_card
                when "Go Back"
                    self.user_profile
                end
            end
        when "View My Previous Transaction"
            self.transactions.reload
            if self.transactions.all == [] || self.transactions.all == nil
                puts "You haven't made any transactions yet!"
                prompt = TTY::Prompt.new
                prompt.keypress("Press enter to continue", keys: [:return])
                self.user_profile
            else
                prompt = TTY::Prompt.new
                choices = self.transactions.map(&:date)
                answer = prompt.select("Which transaction would you like to view?", choices)
                case answer
                when answer
                    self.transactions.reload
                    found_transaction = self.transactions[choices.index(answer)]
                    puts "#{found_transaction.title} item(s) were purchased on this day. The total was #{self.transactions[choices.index(answer)].total}"
                    prompt.keypress("Press enter to continue", keys: [:return])
                    self.user_profile
                end
            end
        when "Go Back to Main Screen"
            main_screen
        end
    end

    def delete_card
        prompt = TTY::Prompt.new
        choices = [self.cards.map{|i| i.bank_name}, "Go Back"].flatten
        answer = prompt.select("Which card would you like to use?", choices)
        if answer == "Go Back"
            self.user_profile
        else
            found_card = self.cards[choices.index(answer)]
            found_card.destroy
            prompt.keypress("Card removed. Press enter to continue", keys: [:return])
            self.user_profile
        end
    end
    
end

