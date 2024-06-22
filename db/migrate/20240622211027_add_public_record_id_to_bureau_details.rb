class AddPublicRecordIdToBureauDetails < ActiveRecord::Migration[6.1]
  def change
    change_column_null :bureau_details, :public_record_id, true
  end
end
