ActiveAdmin.register ClientProfile do
  # Permit parameters for assignment
  permit_params :first_name, :middle_name, :last_name, :ssn_last4, :email, :phone, :client_id

  index do
    selectable_column
    id_column
    column :first_name
    column :middle_name
    column :last_name
    column :ssn_last4
    column :email
    column :phone
    column :client_id
    column :created_at
    column :updated_at
    actions
  end

  filter :first_name
  filter :middle_name
  filter :last_name
  filter :ssn_last4
  filter :email
  filter :phone
  filter :client_id
  filter :created_at
  filter :updated_at

  form do |f|
    f.inputs do
      f.input :first_name
      f.input :middle_name
      f.input :last_name
      f.input :ssn_last4
      f.input :email
      f.input :phone
      f.input :client
    end
    f.actions
  end
end
