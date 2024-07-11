class CreatePersonalInformations < ActiveRecord::Migration[6.1]
  def change
    create_table :personal_informations do |t|
      t.string :name
      t.string :date_of_birth
      t.string :current_addresses
      t.string :previous_addresses
      t.string :employers

      t.timestamps
    end
  end
end
