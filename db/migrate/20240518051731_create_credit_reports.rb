class CreateCreditReports < ActiveRecord::Migration[6.1]
  def change
    create_table :credit_reports do |t|
      t.references :client, null: false, foreign_key: true

      t.timestamps
    end
  end
end
