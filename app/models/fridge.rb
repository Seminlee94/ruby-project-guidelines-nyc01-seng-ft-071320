class Fridge < ActiveRecord::Base
    belongs_to :user
    has_many :items

    def start_fridge
        prompt = TTY::Prompt.new
        choices = ["find an item", "add item(s)", "remove item(s)", "go back to main screen"]
        answer = prompt.select("What would you like to do?", choices)
            case answer
            when "find an item"
                puts "good to go"
                binding.pry
            when "add item(s)"
            when "remove item(s)"
            when "go back to main screen"  
            end
    end

end