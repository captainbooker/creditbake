class AddCreditorNameToAccounts < ActiveRecord::Migration[6.1]
  def change
    add_column :accounts, :creditor_name, :string
  end
end
