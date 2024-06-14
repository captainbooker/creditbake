class AddMailedAndTrackingNumberToLetters < ActiveRecord::Migration[6.1]
  def change
    add_column :letters, :mailed, :boolean
    add_column :letters, :tracking_number, :string
  end
end
