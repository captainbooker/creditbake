class CreateDisputes < ActiveRecord::Migration[6.1]
  def change
    create_table :disputes do |t|
      t.references :client, null: false, foreign_key: true
      t.references :credit_report, null: false, foreign_key: true
      t.string :bureau
      t.string :category
      t.text :account_details
      t.text :inquiry_details

      t.timestamps
    end
  end
end
