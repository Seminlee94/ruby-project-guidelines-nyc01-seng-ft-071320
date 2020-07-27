class User < ActiveRecord::Base
    has_one :fridge
    has_one :cart

    
    def self.login
        choices = [ "Create a New Account.", "Log into My Account"]
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
            r_user.cart.start_cart
        end
    end

    def self.new_id
        puts "Enter a log-in ID."
        username = gets.chomp
        if self.find_by(log_in_id: username) == nil
            puts "Please enter a password"
            password = gets.chomp
            new_user = User.create(log_in_id: username, log_in_pass: password_instance)
            Cart.create(user_id: new_user.id)
            puts "Would you like to start shopping? (y/n)"
            y_n = gets.chomp
            case y_n
            when "y"
                new_user.cart.start_cart
            when "n"
                puts "What would you like to do?"
                puts "Enter 1 to view my profile"
                puts "Enter 2 to view fridge"
            end
        else 
            puts "That log-in ID is not available. Please type in another one."
            self.new_id
        end
    end

end

