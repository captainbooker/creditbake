class AddAddressToInquiries < ActiveRecord::Migration[6.1]
  def change
    add_column :inquiries, :address, :string
  end
end
