class CreateUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :users do |t|
      t.string :log_in_id
      t.string :log_in_pass
      t.string :name
      t.string :address
    end
  end
end
