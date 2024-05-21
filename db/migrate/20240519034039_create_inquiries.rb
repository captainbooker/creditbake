class CreateInquiries < ActiveRecord::Migration[6.1]
  def change
    create_table :inquiries do |t|
      t.string :inquiry_name, null: false
      t.string :type_of_business
      t.date :inquiry_date
      t.string :credit_bureau

      t.timestamps
    end
  end
end
