class AddMailingAddressToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :street_address, :string
    add_column :users, :city, :string
    add_column :users, :state, :string
    add_column :users, :postal_code, :string
    add_column :users, :country, :string
    add_column :users, :ssn_last4, :string
  end
end
