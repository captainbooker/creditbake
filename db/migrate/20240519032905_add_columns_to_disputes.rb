class AddColumnsToDisputes < ActiveRecord::Migration[6.1]
  def change
    remove_column :disputes, :category, :string
    add_column :disputes, :category, :integer, null: false
    add_reference :disputes, :disputable, polymorphic: true, null: false
  end
end
