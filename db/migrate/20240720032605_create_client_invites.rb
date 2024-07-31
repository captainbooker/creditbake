class CreateClientInvites < ActiveRecord::Migration[6.1]
  def change
    create_table :client_invites do |t|
      t.string :token
      t.references :user, null: false, foreign_key: true
      t.datetime :expires_at

      t.timestamps
    end
  end
end
