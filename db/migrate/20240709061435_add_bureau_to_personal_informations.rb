class AddBureauToPersonalInformations < ActiveRecord::Migration[6.1]
  def change
    add_column :personal_informations, :bureau, :string
  end
end
