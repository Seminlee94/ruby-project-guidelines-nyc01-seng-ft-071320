class Fridge < ActiveRecord::Base
    belongs_to :user
    has_many :products
    
    
    def my_fridge
        self.products.reload
        prompt = TTY::Prompt.new
        choices = ["Add Product", "Delete Product", "Find a Product", "Go Back to Main Screen"]
        answer = prompt.select("What would you like to do?", choices)
            case answer
            when "Add Product"
                puts "What would you like to add?"
                prompt = TTY::Prompt.new
                product_title = gets.chomp
                while product_title == ""
                    puts "You must search something!"
                    product_title = gets.chomp
                end
                api_key = ENV["SPOON_API_KEY"]
            json_products = JSON.parse(RestClient.get("https://api.spoonacular.com/food/products/search?query=#{product_title}&number=5&apiKey=#{api_key}"))
            json_product_titles = json_products["products"].map{|i|i["title"]}
            answer = prompt.select("which would you like to add?", json_product_titles)
            case answer
            when answer
                puts "Quantity?"
                product_quantity = gets.chomp.to_i
                while product_quantity < 0
                    puts "Must be greater than 0"
                    puts "Quantity?"
                    product_quantity = gets.chomp.to_i
                end
                found_product = self.products.select{|i| i.title == answer}
                if found_product == []
                    api_id = json_products["products"][json_product_titles.index(answer)]["id"]
                    product = JSON.parse(RestClient.get("https://api.spoonacular.com/food/products/#{api_id}?apiKey=#{api_key}"))
                    new_product = Product.create(title: product["title"], fridge_id: self.id, quantity: product_quantity, price: product["price"], calories: product["nutrition"]["calories"])
                else
                    found_product[0].quantity += product_quantity
                    found_product[0].save
                end
            end
            self.my_fridge

        when "Delete Product"
            self.products.reload
            if self.products == [] || self.products == nil
                puts "Your fridge is empty!"
            else
                prompt = TTY::Prompt.new
                answer = prompt.select("What would you like to delete?", self.products.map(&:title))
                case answer
                when answer
                    found_product = self.products.select{|i| i.title == answer}
                    puts "You have #{found_product[0].quantity} of #{found_product[0].title}(s) in your fridge. How many do you want to take out?"
                    prompt = TTY::Prompt.new
                    remove_quantity = prompt.slider("Quantity?", max: found_product[0].quantity, step: 1)
                    found_product[0].quantity -= remove_quantity
                    found_product[0].save
                    self.products.where(quantity: 0).destroy_all
                end
            end
            self.my_fridge
        
        when "Find a Product"
            self.products.reload
            if self.products == [] || self.products == nil
                puts "Your fridge is empty!"
            else
                prompt = TTY::Prompt.new
                answer = prompt.select("Search:", self.products.map(&:title))
                case answer
                when answer
                    found_product = self.products.select{|i| i.title == answer}
                    puts "You have #{found_product[0].quantity} #{found_product[0].title}(s). It contains #{found_product[0].calories} calories."
                end
            end
            self.my_fridge
        when "Go Back to Main Screen"
            self.user.main_screen
        end
    end


end