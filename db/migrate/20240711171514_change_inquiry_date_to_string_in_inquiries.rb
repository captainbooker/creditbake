class ChangeInquiryDateToStringInInquiries < ActiveRecord::Migration[6.1]
  def up
    change_column :inquiries, :inquiry_date, :string
  end

  def down
    change_column :inquiries, :inquiry_date, :date
  end
end
