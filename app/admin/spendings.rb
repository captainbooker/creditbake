ActiveAdmin.register Spending do
  # Permit parameters for assignment
  permit_params :user_id, :amount, :description, :token

  index do
    selectable_column
    id_column
    column :user_id
    column :amount
    column :description
    column :token
    column :created_at
    column :updated_at
    actions
  end

  filter :user_id
  filter :amount
  filter :description
  filter :token
  filter :created_at
  filter :updated_at

  form do |f|
    f.inputs do
      f.input :user
      f.input :amount
      f.input :description
      f.input :token
    end
    f.actions
  end
end
