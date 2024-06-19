ActiveAdmin.register Account do
  # Permit parameters for assignment
  permit_params :account_number, :account_type, :account_type_detail, :account_status, :challenge, :user_id, :creditor_name, :name

  index do
    selectable_column
    id_column
    column :account_number
    column :account_type
    column :account_type_detail
    column :account_status
    column :challenge
    column :creditor_name
    column :name
    column :created_at
    column :updated_at
    actions
  end

  filter :account_number
  filter :account_type
  filter :account_type_detail
  filter :account_status
  filter :challenge
  filter :creditor_name
  filter :name
  filter :created_at
  filter :updated_at

  form do |f|
    f.inputs do
      f.input :account_number
      f.input :account_type
      f.input :account_type_detail
      f.input :account_status
      f.input :challenge
      f.input :user
      f.input :creditor_name
      f.input :name
    end
    f.actions
  end
end
