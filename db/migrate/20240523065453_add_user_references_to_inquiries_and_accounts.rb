class AddUserReferencesToInquiriesAndAccounts < ActiveRecord::Migration[6.1]
  def change
    add_reference :inquiries, :user, null: false, foreign_key: true
    add_reference :accounts, :user, null: false, foreign_key: true
  end
end
