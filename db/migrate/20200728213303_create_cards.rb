class CreateCards < ActiveRecord::Migration[5.2]
  def change
    create_table :cards do |t|
      t.integer :user_id
      t.string :name
      t.integer :card_number
      t.integer :expiration_date
      t.integer :CVV
    end
  end
  end
end
