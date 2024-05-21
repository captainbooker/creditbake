class CreateBureauDetails < ActiveRecord::Migration[6.1]
  def change
    create_table :bureau_details do |t|
      t.references :account, null: false, foreign_key: true
      t.integer :bureau, null: false
      t.decimal :balance_owed, precision: 10, scale: 2
      t.decimal :high_credit, precision: 10, scale: 2
      t.decimal :credit_limit, precision: 10, scale: 2
      t.decimal :past_due_amount, precision: 10, scale: 2
      t.string :payment_status
      t.date :date_opened
      t.date :date_of_last_payment
      t.date :last_reported

      t.timestamps
    end
  end
end
