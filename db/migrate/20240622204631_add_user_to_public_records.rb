class AddUserToPublicRecords < ActiveRecord::Migration[6.1]
  def change
    add_reference :public_records, :user, null: false, foreign_key: true
  end
end
