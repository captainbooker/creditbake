class RenameTypeColumnInPublicRecords < ActiveRecord::Migration[6.1]
  def change
    rename_column :public_records, :type, :public_record_type
  end
end
