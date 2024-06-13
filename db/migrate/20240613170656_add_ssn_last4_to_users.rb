class AddSsnLast4ToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :encrypted_ssn_last4, :string
    add_column :users, :encrypted_ssn_last4_iv, :string
    add_column :users, :ssn_last4_bidx, :string
  end
end
