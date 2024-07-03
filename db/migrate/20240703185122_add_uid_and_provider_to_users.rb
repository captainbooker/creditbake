class AddUidAndProviderToUsers < ActiveRecord::Migration[6.1]
  def change
    add_index :users, [:uid, :provider], unique: true
  end
end
