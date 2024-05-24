class CreateLetters < ActiveRecord::Migration[6.1]
  def change
    create_table :letters do |t|
      t.string :name
      t.string :bureau
      t.text :experian_document
      t.text :transunion_document
      t.text :equifax_document
      t.references :user

      t.timestamps
    end
  end
end
