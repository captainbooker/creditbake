class ChangeClientIdToAllowNullInCreditReports < ActiveRecord::Migration[6.1]
  def change
    change_column_null :credit_reports, :client_id, true
  end
end
