class AddFreeAttackToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :free_attack, :integer
  end
end
