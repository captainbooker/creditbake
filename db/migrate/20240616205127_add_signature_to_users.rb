class AddSignatureToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :signature, :text
  end
end
