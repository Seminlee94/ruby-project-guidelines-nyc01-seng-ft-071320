require 'tty-prompt'


class Cart < ActiveRecord::Base
    belongs_to :user
    has_many :items

    def start_cart
        prompt = TTY::Prompt.new
        choices = ["find an item", "view your sum", "view your cart", "go back to main screen"]
        answer = prompt.select("What would you like to do?", choices)
            case answer
            when "find an item"
                puts "good to go"
            when "view your sum"
            when "view your cart"
            when "go back to main screen"  
            end
    end

end
