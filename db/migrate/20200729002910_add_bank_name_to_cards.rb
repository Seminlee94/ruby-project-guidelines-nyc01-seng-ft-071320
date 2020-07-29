class AddBankNameToCards < ActiveRecord::Migration[5.2]
  def change
    add_column :cards, :bank_name, :string
  end
end
