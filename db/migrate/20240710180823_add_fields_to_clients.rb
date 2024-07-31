class AddFieldsToClients < ActiveRecord::Migration[6.1]
  def change
    add_column :clients, :email, :string, default: "", null: false
    add_column :clients, :phone_number, :string
    add_column :clients, :first_name, :string
    add_column :clients, :last_name, :string
    add_column :clients, :street_address, :string
    add_column :clients, :city, :string
    add_column :clients, :state, :string
    add_column :clients, :postal_code, :string
    add_column :clients, :country, :string
    add_column :clients, :ssn_last4, :string
    add_column :clients, :encrypted_ssn_last4, :string
    add_column :clients, :encrypted_ssn_last4_iv, :string
    add_column :clients, :ssn_last4_bidx, :string
    add_column :clients, :slug, :string
    add_column :clients, :signature, :text
    add_column :clients, :agreement, :boolean

    add_index :clients, :email, unique: true
  end
end
