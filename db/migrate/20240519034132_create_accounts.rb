class CreateAccounts < ActiveRecord::Migration[6.1]
  def change
    create_table :accounts do |t|
      t.string :account_number, null: false
      t.string :account_type
      t.string :account_type_detail
      t.string :account_status

      t.timestamps
    end
  end
end
