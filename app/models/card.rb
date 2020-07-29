class Card < ActiveRecord::Base
    belongs_to :user

    def card_numbers
        binding.pry
        self.map(&:card_number)
    end



end