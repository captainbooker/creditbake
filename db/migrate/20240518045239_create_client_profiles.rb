class CreateClientProfiles < ActiveRecord::Migration[6.1]
  def change
    create_table :client_profiles do |t|
      t.string :first_name
      t.string :middle_name
      t.string :last_name
      t.string :ssn_last4
      t.string :email
      t.string :phone
      t.references :client, null: false, foreign_key: true

      t.timestamps
    end
  end
end
