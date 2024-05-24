class AddUsernameToCreditReports < ActiveRecord::Migration[6.1]
  def change
    add_column :credit_reports, :username, :string
    add_column :credit_reports, :password, :string
    add_column :credit_reports, :security_question, :string
  end
end
