class ChangeAmountInSpendings < ActiveRecord::Migration[6.1]
  def change
    change_column :spendings, :amount, :decimal, precision: 10, scale: 2, null: false
  end
end
