class RemoveForeignKeys < ActiveRecord::Migration[6.1]
  def change
    remove_foreign_key :inquiries, :users
    add_foreign_key :inquiries, :users, on_delete: :cascade
  end
end
