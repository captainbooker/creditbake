class RemoveForeignKeysOnAccounts < ActiveRecord::Migration[6.1]
  def change
    remove_foreign_key :accounts, :users
    add_foreign_key :accounts, :users, on_delete: :cascade
  end
end
