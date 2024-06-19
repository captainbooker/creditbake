ActiveAdmin.register Client do
  # Permit parameters for assignment
  permit_params :name, :user_id

  index do
    selectable_column
    id_column
    column :name
    column :user_id
    column :created_at
    column :updated_at
    actions
  end

  filter :name
  filter :user_id
  filter :created_at
  filter :updated_at

  form do |f|
    f.inputs do
      f.input :name
      f.input :user
    end
    f.actions
  end
end
