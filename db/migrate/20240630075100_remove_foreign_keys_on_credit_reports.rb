class RemoveForeignKeysOnCreditReports < ActiveRecord::Migration[6.1]
  def change
    remove_foreign_key :credit_reports, :users
    remove_foreign_key :public_records, :users
    remove_foreign_key :spendings, :users
    add_foreign_key :credit_reports, :users, on_delete: :cascade
    add_foreign_key :public_records, :users, on_delete: :cascade
    add_foreign_key :spendings, :users, on_delete: :cascade

    remove_foreign_key :bureau_details, :accounts
    add_foreign_key :bureau_details, :accounts, on_delete: :cascade
  end
end
