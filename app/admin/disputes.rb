ActiveAdmin.register Dispute do
  # Permit parameters for assignment
  permit_params :client_id, :credit_report_id, :bureau, :account_details, :inquiry_details, :payment_status, :account_rating, :creditor_type, :account_status, :balance_owed, :date_opened, :high_balance, :closed_date, :account_description, :dispute_status, :creditor_remarks, :payment_amount, :last_payment, :term_length, :past_due_amount, :account_type, :open, :payment_frequency, :credit_limit, :date_of_last_activity, :date_reported, :last_verified, :last_reported_on, :address, :account_number, :inquiry_date, :category, :disputable_type, :disputable_id

  index do
    selectable_column
    id_column
    column :client_id
    column :credit_report_id
    column :bureau
    column :account_details
    column :inquiry_details
    column :payment_status
    column :account_rating
    column :creditor_type
    column :account_status
    column :balance_owed
    column :date_opened
    column :high_balance
    column :closed_date
    column :account_description
    column :dispute_status
    column :creditor_remarks
    column :payment_amount
    column :last_payment
    column :term_length
    column :past_due_amount
    column :account_type
    column :open
    column :payment_frequency
    column :credit_limit
    column :date_of_last_activity
    column :date_reported
    column :last_verified
    column :last_reported_on
    column :address
    column :account_number
    column :inquiry_date
    column :category
    column :disputable_type
    column :disputable_id
    column :created_at
    column :updated_at
    actions
  end

  filter :client_id
  filter :credit_report_id
  filter :bureau
  filter :account_details
  filter :inquiry_details
  filter :payment_status
  filter :account_rating
  filter :creditor_type
  filter :account_status
  filter :balance_owed
  filter :date_opened
  filter :high_balance
  filter :closed_date
  filter :account_description
  filter :dispute_status
  filter :creditor_remarks
  filter :payment_amount
  filter :last_payment
  filter :term_length
  filter :past_due_amount
  filter :account_type
  filter :open
  filter :payment_frequency
  filter :credit_limit
  filter :date_of_last_activity
  filter :date_reported
  filter :last_verified
  filter :last_reported_on
  filter :address
  filter :account_number
  filter :inquiry_date
  filter :category
  filter :disputable_type
  filter :disputable_id
  filter :created_at
  filter :updated_at

  form do |f|
    f.inputs do
      f.input :client
      f.input :credit_report
      f.input :bureau
      f.input :account_details
      f.input :inquiry_details
      f.input :payment_status
      f.input :account_rating
      f.input :creditor_type
      f.input :account_status
      f.input :balance_owed
      f.input :date_opened
      f.input :high_balance
      f.input :closed_date
      f.input :account_description
      f.input :dispute_status
      f.input :creditor_remarks
      f.input :payment_amount
      f.input :last_payment
      f.input :term_length
      f.input :past_due_amount
      f.input :account_type
      f.input :open
      f.input :payment_frequency
      f.input :credit_limit
      f.input :date_of_last_activity
      f.input :date_reported
      f.input :last_verified
      f.input :last_reported_on
      f.input :address
      f.input :account_number
      f.input :inquiry_date
      f.input :category
      f.input :disputable_type
      f.input :disputable_id
    end
    f.actions
  end
end
