class CreateSubscriptions < ActiveRecord::Migration[6.1]
  def change
    create_table :subscriptions do |t|
      t.string :name
      t.text :description
      t.decimal :price
      t.integer :duration

      t.timestamps
    end
  end
end
