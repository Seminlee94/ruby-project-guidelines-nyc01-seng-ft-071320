require 'rest-client'
require 'json'
require 'pry'

User.delete_all
Cart.delete_all
Fridge.delete_all
Product.delete_all
Card.delete_all
Transaction.delete_all


user1 = User.create(log_in_id: "example1", log_in_pass: "123", name: "Ryan", address: "1 Elm st.")
user2 = User.create(log_in_id: "example2", log_in_pass: "123", name: "Mandy", address: "2 Elm st.")
user3 = User.create(log_in_id: "example3", log_in_pass: "123", name: "Susan", address: "3 Elm st.")
user4 = User.create(log_in_id: "example4", log_in_pass: "123", name: "Greg", address: "4 Elm st.")
user5 = User.create(log_in_id: "example5", log_in_pass: "123", name: "Roger", address: "5 Elm st.")
user6 = User.create(log_in_id: "example6", log_in_pass: "123", name: "Mike", address: "6 Elm st.")

card1 = Card.create(bank_name: "JP Morgan Chase", name: "Ryan", card_number: 11111, expiration_date: 1111, CVV: 111, balance: 20000.00, user_id: user1.id)
card2 = Card.create(bank_name: "Bank of America", name: "Ryan", card_number: 22222, expiration_date: 2222, CVV: 222, balance: 3000.00, user_id: user1.id)
card3 = Card.create(bank_name: "TD Bank", name: "Ryan", card_number: 33333, expiration_date: 3333, CVV: 333, balance: 4000.00, user_id: user1.id)

cart1 = Cart.create(user_id: user1.id)
cart2 = Cart.create(user_id: user1.id)
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

product1 = Product.create(cart_id: cart1.id, fridge_id: nil, title: "THIS SHOULD BE IN RYANS FRIDGE", price: 2.50, quantity: 4, calories: 49)
product2 = Product.create(cart_id: cart1.id, fridge_id: nil, title: "cucumber", price: 1.50, quantity: 1, calories: 4)
product3 = Product.create(cart_id: cart1.id, fridge_id: nil, title: "chicken", price: 12.50, quantity: 2, calories: 400)
product4 = Product.create(cart_id: cart1.id, fridge_id: nil, title: "lettuce", price: 4.50, quantity: 10, calories: 43)
product5 = Product.create(cart_id: cart2.id, fridge_id: nil, title: "mayo", price: 5, calories: 600)
product6 = Product.create(cart_id: cart2.id, fridge_id: nil, title: "milk", price: 4.5, calories: 34)
product7 = Product.create(cart_id: cart2.id, fridge_id: nil, title: "juice", price: 2.50, calories: 48)
product8 = Product.create(cart_id: cart2.id, fridge_id: nil, title: "beef", price: 7.50, calories: 300)
product9 = Product.create(cart_id: nil, fridge_id: fridge1.id, title: "beef", price: 7.50, calories: 300, quantity: 1)
product10 = Product.create(cart_id: nil, fridge_id: fridge1.id, title: "beef", price: 7.50, calories: 300, quantity: 2)
product11 = Product.create(cart_id: nil, fridge_id: fridge1.id, title: "beef", price: 7.50, calories: 300, quantity: 3)
product12 = Product.create(cart_id: nil, fridge_id: fridge1.id, title: "chicken", price: 8.50, calories: 300)
product13 = Product.create(cart_id: nil, fridge_id: fridge1.id, title: "pork", price: 9.50, calories: 300)
product14 = Product.create(cart_id: nil, fridge_id: fridge2.id, title: "salmon", price: 6.50, calories: 300)
product15 = Product.create(cart_id: nil, fridge_id: fridge2.id, title: "tuny", price: 5.50, calories: 350)

transaction1 = Transaction.create(user_id: user1.id, cart_id: cart1.id, title: cart1.products.map(&:title), date: "2020-07-29 00:09:07 -0400")
transaction1 = Transaction.create(user_id: user1.id, cart_id: cart2.id, title: cart2.products.map(&:title), date: "2020-07-29 00:11:40 -0400")


# products = RestClient.get("https://api.spoonacular.com/food/products/search?query=#{product_title}&number=5&apiKey=6bdcf4fe78474fd5a0f51e67c05b8985")
# product = RestClient.get("https://api.spoonacular.com/food/products/214146?apiKey=6bdcf4fe78474fd5a0f51e67c05b8985")
# product_data = JSON.parse(products)
# product_id = product_data["products"][0]["id"]
# product = RestClient.get("https://api.spoonacular.com/food/products/#{product_id}?apiKey=6bdcf4fe78474fd5a0f51e67c05b8985")
# product_info = JSON.parse(product)
# binding.pry

# products => {id1: "yogurt1", id2: "yogurt2"}

# user gets all values

# value they choose, they are presented key and given info on product