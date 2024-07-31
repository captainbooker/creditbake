class AddMaverickCardTokenToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :maverick_card_token, :string
  end
end
