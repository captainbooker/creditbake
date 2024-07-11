class AddUserIdToPersonalInformations < ActiveRecord::Migration[6.1]
  def change
    add_column :personal_informations, :user_id, :integer
  end
end
