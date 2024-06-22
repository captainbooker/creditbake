class CreatePublicRecords < ActiveRecord::Migration[6.1]
  def change
    create_table :public_records do |t|
      t.string :type
      t.string :status
      t.string :date_filed_reported
      t.string :reference_number
      t.string :closing_date
      t.string :asset_amount
      t.string :court
      t.string :liability
      t.string :exempt_amount
      t.timestamps
    end
  end
end
