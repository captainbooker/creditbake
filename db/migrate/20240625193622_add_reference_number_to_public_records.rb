class AddReferenceNumberToPublicRecords < ActiveRecord::Migration[6.1]
  def change
    add_column :public_records, :reference_number, :string
    remove_column(:bureau_details, :reference_number)
  end
end
