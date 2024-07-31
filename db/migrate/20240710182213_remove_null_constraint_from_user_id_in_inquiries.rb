class RemoveNullConstraintFromUserIdInInquiries < ActiveRecord::Migration[6.1]
  def change
    change_column_null :inquiries, :user_id, true
    change_column_null :accounts, :user_id, true
    change_column_null :credit_reports, :user_id, true
    change_column_null :letters, :user_id, true
    change_column_null :spendings, :user_id, true
    change_column_null :mailings, :user_id, true
    change_column_null :public_records, :user_id, true
    change_column_null :personal_informations, :user_id, true
  end
end
