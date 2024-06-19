ActiveAdmin.register Mailing do
  # Permit parameters for assignment
  permit_params :user_id, :letter_id, :pages, :color, :cost

  index do
    selectable_column
    id_column
    column :user_id
    column :letter_id
    column :pages
    column :color
    column :cost
    column :created_at
    column :updated_at
    actions
  end

  filter :user_id
  filter :letter_id
  filter :pages
  filter :color
  filter :cost
  filter :created_at
  filter :updated_at

  form do |f|
    f.inputs do
      f.input :user
      f.input :letter
      f.input :pages
      f.input :color
      f.input :cost
    end
    f.actions
  end
end
