class AddMaverickRecurringIdToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :maverick_recurring_id, :string
  end
end
