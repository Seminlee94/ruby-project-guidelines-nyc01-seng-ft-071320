class Card < ActiveRecord::Base
    belongs_to :user

    def self.new_card(given_user_id, given_user_name)
        prompt = TTY::Prompt.new
        puts "Please enter your card information"
        puts "Name of Bank:"
        name_of_bank = gets.chomp.to_s
        puts "Card Number: "
        number = gets.chomp.to_i
        puts "Expiration Date: (MMYYYY)"
        date = gets.chomp.to_i
        puts "CVV:"
        cvv_number = gets.chomp.to_i
        new_card = Card.create(bank_name: name_of_bank, user_id: given_user_id, name: given_user_name, card_number: number, expiration_date: date, CVV: cvv_number, balance: 20000000)
        prompt.keypress("Card added. Press enter to continue", keys: [:return])
        new_card.user.user_profile
    end

end