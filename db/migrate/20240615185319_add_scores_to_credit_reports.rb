class AddScoresToCreditReports < ActiveRecord::Migration[6.1]
  def change
    add_column :credit_reports, :experian_score, :integer
    add_column :credit_reports, :transunion_score, :integer
    add_column :credit_reports, :equifax_score, :integer
    add_column :credit_reports, :experian_score_change, :integer
    add_column :credit_reports, :transunion_score_change, :integer
    add_column :credit_reports, :equifax_score_change, :integer
  end
end
