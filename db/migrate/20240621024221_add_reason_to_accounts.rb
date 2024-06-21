class AddReasonToAccounts < ActiveRecord::Migration[6.1]
  def change
    add_column :accounts, :reason, :string
  end
end
