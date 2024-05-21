class RenameInquiryNameToNameInInquiries < ActiveRecord::Migration[6.1]
  def change
    remove_column :disputes, :inquiry_name, :name
    add_column :accounts, :challenge, :boolean, default: false, null: false
    add_column :inquiries, :challenge, :boolean, default: false, null: false

    change_column :bureau_details, :balance_owed, :string
    change_column :bureau_details, :high_credit, :string
    change_column :bureau_details, :credit_limit, :string
    change_column :bureau_details, :past_due_amount, :string
    change_column :bureau_details, :payment_status, :string
    change_column :bureau_details, :date_opened, :string
    change_column :bureau_details, :date_of_last_payment, :string
    change_column :bureau_details, :last_reported, :string
  end
end
