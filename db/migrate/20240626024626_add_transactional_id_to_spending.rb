class AddTransactionalIdToSpending < ActiveRecord::Migration[6.1]
  def change
    add_column :spendings, :transactional_id, :string, null: true, unique: true
  end
end
