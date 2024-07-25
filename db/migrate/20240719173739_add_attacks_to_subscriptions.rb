class AddAttacksToSubscriptions < ActiveRecord::Migration[6.1]
  def change
    add_column :subscriptions, :attacks, :integer
  end
end
