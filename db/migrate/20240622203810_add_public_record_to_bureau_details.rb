class AddPublicRecordToBureauDetails < ActiveRecord::Migration[6.1]
  def change
    add_reference :bureau_details, :public_record, null: false, foreign_key: true
    change_column_null :bureau_details, :account_id, true
    add_column :bureau_details, :status, :string
    add_column :bureau_details, :date_filed_reported, :string
    add_column :bureau_details, :reference_number, :string
    add_column :bureau_details, :closing_date, :string
    add_column :bureau_details, :asset_amount, :string
    add_column :bureau_details, :court, :string
    add_column :bureau_details, :liability, :string
    add_column :bureau_details, :exempt_amount, :string


    remove_column :public_records, :status
    remove_column :public_records, :date_filed_reported
    remove_column :public_records, :reference_number
    remove_column :public_records, :closing_date
    remove_column :public_records, :asset_amount
    remove_column :public_records, :court
    remove_column :public_records, :liability
    remove_column :public_records, :exempt_amount
  end
end
