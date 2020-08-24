class Fridge < ActiveRecord::Base
    belongs_to :user
    has_many :products
    
    
    def my_fridge
        self.products.reload
        prompt = TTY::Prompt.new
        choices = ["Add Product", "Delete Product", "Find a Product", "View Possible Menu", "Go Back to Main Screen"]
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
                # api_key = ENV["SPOON_API"]
                ## Using API to retrieve items searched
            json_products = JSON.parse(RestClient.get("https://api.spoonacular.com/food/products/search?query=#{product_title}&number=5&apiKey=#{api_key}"))
            if json_products["products"] == []
                prompt = TTY::Prompt.new
               prompt.keypress("It looks like the grocery store does not carry this! Press enter to continue", keys: [:return])
            else
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
                        ## Using API to grab a particular item and find its price & calories
                        product = JSON.parse(RestClient.get("https://api.spoonacular.com/food/products/#{api_id}?apiKey=#{api_key}"))
                        new_product = Product.create(title: product["title"], fridge_id: self.id, quantity: product_quantity, price: product["price"], calories: product["nutrition"]["calories"])
                    else
                        found_product[0].quantity += product_quantity
                        found_product[0].save
                    end
                end
            end
            self.my_fridge
        when "Delete Product"
            self.products.reload
            if self.products == [] || self.products == nil
                prompt = TTY::Prompt.new
                prompt.keypress("Your fridge is empty! Press enter to continue", keys: [:return])
            else
                prompt = TTY::Prompt.new
                answer = prompt.select("What would you like to delete?", self.products.map(&:title))
                found_product = self.products.select{|i| i.title == answer}
                puts "You have #{found_product[0].quantity} of #{found_product[0].title}(s) in your fridge. How many do you want to take out?"
                prompt = TTY::Prompt.new
                remove_quantity = prompt.slider("Quantity?", max: found_product[0].quantity, step: 1)
                found_product[0].quantity -= remove_quantity
                found_product[0].save
                self.products.where(quantity: 0).destroy_all
            end
            self.my_fridge
        when "Find a Product"
            self.products.reload
            if self.products == [] || self.products == nil
                prompt = TTY::Prompt.new
                prompt.keypress("Your fridge is empty! Press enter to continue", keys: [:return])
            else
                prompt = TTY::Prompt.new
                answer = prompt.select("Search:", self.products.map(&:title))
                found_product = self.products.select{|i| i.title == answer}
                prompt.keypress("You have #{found_product[0].quantity} #{found_product[0].title}(s). It contains #{found_product[0].calories} calories. Press Enter to Continue", keys: [:return])
            end
            self.my_fridge
        when "View Possible Menu"
            self.possible_menu
        when "Go Back to Main Screen"
            self.user.main_screen
        end
    end

    def possible_menu
        if self.products == [] || self.products == nil
            prompt = TTY::Prompt.new
            prompt.keypress("Your fridge is empty! Press enter to continue", keys: [:return])
            self.my_fridge
        else
            prompt = TTY::Prompt.new
            choices = [self.products.map(&:title), "Go Back"].flatten
            answer = prompt.multi_select("Which ingredients would you prefer to use?", choices)
            if answer == ["Go Back"]
                self.my_fridge
            else 
                ing = answer.join(",+")
                api_key = ENV["SPOON_API_KEY"]
                # api_key = ENV["SPOON_API"]
                list = JSON.parse(RestClient.get("https://api.spoonacular.com/recipes/findByIngredients?ingredients=#{ing}&number=5&apiKey=#{api_key}"))
                recipe_options = list.map{|i|i["title"]}
                choice = [recipe_options, "Go Back"].flatten
                recipe_select = prompt.select("Which recipe would you like to view?", choice)
                if recipe_select == "Go Back"
                    self.possible_menu
                else
                    recipe_title = list.select{|i|i["title"] == recipe_select}
                    recipe_id = recipe_title.map{|i|i["id"]}[0]
                    # api_key = ENV["SPOON_API"]
                    api_key = ENV["SPOON_API_KEY"]
                    ## Using API to find recipe for a particular menu
                    analyze_menu = JSON.parse(RestClient.get("https://api.spoonacular.com/recipes/#{recipe_id}/analyzedInstructions?apiKey=#{api_key}"))
                    if analyze_menu == [] || analyze_menu == nil
                        prompt = TTY::Prompt.new
                        answer = prompt.select("Sorry, we couldn't find the instruction for this recipe. Would you like to choose different recipe?", %w(yes no))
                        case answer
                        when "yes"
                            self.possible_menu
                        when "no"
                            self.user.main_screen
                        end
                    else 
                        steps = analyze_menu[0]["steps"].map{|i| i["step"]}.each_with_index{|step, index|
                            puts "Step #{index+1}. #{step}"}
                    end
                end
                shop_for_ingredients(recipe_title[0])
            end
        end
    end
    
    def shop_for_ingredients(recipe)
        prompt = TTY::Prompt.new
        missed_id = recipe["missedIngredients"].map{|i|i["id"]}
        missed_title = recipe["missedIngredients"].map{|i|i["name"]}
        choices = [missed_title, "No, I would like to search for a new recipe.", "I have everything that I need."]
        answer = prompt.multi_select("You're missing some ingredients. Which ones would you like to buy?", choices).flatten
        if answer == ["No, I would like to search for a new recipe."]
            self.possible_menu
        elsif answer == ["I have everything that I need."]
            self.my_fridge
        else
            missing_item = answer.map{|answer1| recipe["missedIngredients"].select{|i|i["name"]==answer1}}
            missing_id = missing_item.flatten.map{|i|i["id"]}
            missing_id.each do |i|
                i
                api_key = ENV["SPOON_API_KEY"]
                # api_key = ENV["SPOON_API"]
                missing_product = JSON.parse(RestClient.get("https://api.spoonacular.com/food/products/#{i}?apiKey=#{api_key}"){ |response, request, result, &block|
                ## If there is no data for a recipe, it will throw an error page
                    case response.code
                    when 400 ## error page
                        p "It seems the grocery store is out of this!"
                        self.my_fridge
                    when 200 ## success page
                        response
                    end}, quirks_mode: true )
                find_item = missing_item.flatten.select{|item|item["id"] == i}
                puts "Name: #{find_item[0]["name"]}, price: $#{missing_product["price"]}, calories: #{missing_product["nutrition"]["calories"]}."
                new_product = Product.create(cart_id: self.user.cart.id, title: find_item[0]["name"], quantity: 1, calories: missing_product["nutrition"]["calories"], price: missing_product["price"])
            end
            self.user.cart.start_cart
        end
    end


end