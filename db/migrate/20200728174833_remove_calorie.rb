class RemoveCalorie < ActiveRecord::Migration[5.2]
  def change
    remove_column :products, :calorie
    add_column :products, :calories, :float
  end
end
