class AddTokenToSpendings < ActiveRecord::Migration[6.1]
  def change
    add_column :spendings, :token, :string
  end
end
