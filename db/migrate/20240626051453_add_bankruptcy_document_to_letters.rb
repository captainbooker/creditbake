class AddBankruptcyDocumentToLetters < ActiveRecord::Migration[6.1]
  def change
    add_column :letters, :bankruptcy_document, :text
  end
end
