class AddCommentToBureauDetails < ActiveRecord::Migration[6.1]
  def change
    add_column :bureau_details, :comment, :string
    add_column :bureau_details, :monthly_payment, :string
    add_column :bureau_details, :two_year_payment_history, :json
  end
end
