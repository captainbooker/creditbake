class AddDetailsToDisputes < ActiveRecord::Migration[6.1]
  def change
    add_column :disputes, :payment_status, :string
    add_column :disputes, :account_rating, :string
    add_column :disputes, :creditor_type, :string
    add_column :disputes, :account_status, :string
    add_column :disputes, :balance_owed, :string
    add_column :disputes, :date_opened, :string
    add_column :disputes, :high_balance, :string
    add_column :disputes, :closed_date, :string
    add_column :disputes, :account_description, :string
    add_column :disputes, :dispute_status, :string
    add_column :disputes, :creditor_remarks, :string
    add_column :disputes, :payment_amount, :string
    add_column :disputes, :last_payment, :string
    add_column :disputes, :term_length, :string
    add_column :disputes, :past_due_amount, :string
    add_column :disputes, :account_type, :string
    add_column :disputes, :open, :boolean
    add_column :disputes, :payment_frequency, :string
    add_column :disputes, :credit_limit, :string
    add_column :disputes, :date_of_last_activity, :string
    add_column :disputes, :date_reported, :string
    add_column :disputes, :last_verified, :string
    add_column :disputes, :last_reported_on, :string
    add_column :disputes, :address, :string
    add_column :disputes, :account_number, :string
    add_column :disputes, :inquiry_name, :string
    add_column :disputes, :inquiry_date, :string
  end
end
