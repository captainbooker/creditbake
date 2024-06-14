class CreateMailings < ActiveRecord::Migration[6.1]
  def change
    create_table :mailings do |t|
      t.references :user, null: false, foreign_key: true
      t.references :letter, null: false, foreign_key: true
      t.integer :pages
      t.boolean :color
      t.decimal :cost

      t.timestamps
    end
  end
end
