class AddTrackingNumbersToLetters < ActiveRecord::Migration[6.1]
  def change
    add_column :letters, :experian_tracking_number, :string
    add_column :letters, :transunion_tracking_number, :string
    add_column :letters, :equifax_tracking_number, :string
  end
end
