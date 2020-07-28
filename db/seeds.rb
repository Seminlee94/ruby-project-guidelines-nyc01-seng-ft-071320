require 'rest-client'
require 'json'
require 'pry'

User.delete_all
Cart.delete_all
Fridge.delete_all

user1 = User.create(log_in_id: "example1", log_in_pass: "123", name: "Ryan", address: "1 Elm st.")
user2 = User.create(log_in_id: "example2", log_in_pass: "123", name: "Mandy", address: "2 Elm st.")
user3 = User.create(log_in_id: "example3", log_in_pass: "123", name: "Susan", address: "3 Elm st.")
user4 = User.create(log_in_id: "example4", log_in_pass: "123", name: "Greg", address: "4 Elm st.")
user5 = User.create(log_in_id: "example5", log_in_pass: "123", name: "Roger", address: "5 Elm st.")
user6 = User.create(log_in_id: "example6", log_in_pass: "123", name: "Mike", address: "6 Elm st.")

cart1 = Cart.create(user_id: user1.id)
cart2 = Cart.create(user_id: user2.id)
cart3 = Cart.create(user_id: user3.id)
cart4 = Cart.create(user_id: user4.id)
cart5 = Cart.create(user_id: user5.id)
cart6 = Cart.create(user_id: user6.id)

fridge1 = Fridge.create(user_id: user1.id)
fridge2 = Fridge.create(user_id: user2.id)
fridge3 = Fridge.create(user_id: user3.id)
fridge4 = Fridge.create(user_id: user4.id)
fridge5 = Fridge.create(user_id: user5.id)
fridge6 = Fridge.create(user_id: user6.id)


# products = RestClient.get("https://api.spoonacular.com/food/products/search?query=yogurt&number=5&apiKey=6bdcf4fe78474fd5a0f51e67c05b8985")
# binding.pry

# products => {id1: "yogurt1", id2: "yogurt2"}

# user gets all values

# value they choose, they are presented key and given info on product