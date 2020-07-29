class AddTotalToTransactions < ActiveRecord::Migration[5.2]
  def change
    add_column :transactions, :total, :float
  end
end
