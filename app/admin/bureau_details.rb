ActiveAdmin.register BureauDetail do
  # Permit parameters for assignment
  permit_params :account_id, :bureau, :balance_owed, :high_credit, :credit_limit, :past_due_amount, :payment_status, :date_opened, :date_of_last_payment, :last_reported

  index do
    selectable_column
    id_column
    column :account_id
    column :bureau
    column :balance_owed
    column :high_credit
    column :credit_limit
    column :past_due_amount
    column :payment_status
    column :date_opened
    column :date_of_last_payment
    column :last_reported
    column :created_at
    column :updated_at
    actions
  end

  filter :account_id
  filter :bureau
  filter :balance_owed
  filter :high_credit
  filter :credit_limit
  filter :past_due_amount
  filter :payment_status
  filter :date_opened
  filter :date_of_last_payment
  filter :last_reported
  filter :created_at
  filter :updated_at

  form do |f|
    f.inputs do
      f.input :account
      f.input :bureau
      f.input :balance_owed
      f.input :high_credit
      f.input :credit_limit
      f.input :past_due_amount
      f.input :payment_status
      f.input :date_opened
      f.input :date_of_last_payment
      f.input :last_reported
    end
    f.actions
  end
end
