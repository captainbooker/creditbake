class CreateSpendings < ActiveRecord::Migration[6.1]
  def change
    create_table :spendings do |t|
      t.references :user, null: false, foreign_key: true
      t.decimal :amount
      t.string :description

      t.timestamps
    end
  end
end
