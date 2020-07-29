# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_07_29_033904) do

  create_table "cards", force: :cascade do |t|
    t.string "name"
    t.integer "card_number"
    t.integer "expiration_date"
    t.integer "CVV"
    t.integer "user_id"
    t.float "balance"
    t.string "bank_name"
  end

  create_table "carts", force: :cascade do |t|
    t.integer "user_id"
  end

  create_table "fridges", force: :cascade do |t|
    t.integer "user_id"
  end

  create_table "products", force: :cascade do |t|
    t.integer "cart_id"
    t.integer "fridge_id"
    t.string "title"
    t.float "price"
    t.integer "quantity"
    t.float "calories"
  end

  create_table "transactions", force: :cascade do |t|
    t.integer "user_id"
    t.integer "cart_id"
    t.string "date"
    t.string "title"
  end

  create_table "users", force: :cascade do |t|
    t.string "log_in_id"
    t.string "log_in_pass"
    t.string "name"
    t.string "address"
  end

end
