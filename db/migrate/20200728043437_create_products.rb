class CreateProducts < ActiveRecord::Migration[5.2]
  def change
    create_table :products do |t|
      t.integer :cart_id
      t.integer :fridge_id
      t.string :title
      t.float :price
      t.integer :calorie
    end
  end
end
