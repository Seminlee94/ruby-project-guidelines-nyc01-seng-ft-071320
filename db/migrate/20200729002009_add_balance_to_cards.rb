class AddBalanceToCards < ActiveRecord::Migration[5.2]
  def change
    add_column :cards, :balance, :float
  end
end
