class AddMaverickCustomerIdToUser < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :maverick_customer_id, :string
    add_column :users, :maverick_customer_token, :string
    add_column :users, :maverick_hosted_form_url, :string
    add_column :users, :maverick_card_id, :string
  end
end
