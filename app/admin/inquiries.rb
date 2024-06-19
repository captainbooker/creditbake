ActiveAdmin.register Inquiry do
  # Permit parameters for assignment
  permit_params :inquiry_name, :type_of_business, :inquiry_date, :credit_bureau, :challenge, :user_id, :address

  index do
    selectable_column
    id_column
    column :inquiry_name
    column :type_of_business
    column :inquiry_date
    column :credit_bureau
    column :challenge
    column :user_id
    column :address
    column :created_at
    column :updated_at
    actions
  end

  filter :inquiry_name
  filter :type_of_business
  filter :inquiry_date
  filter :credit_bureau
  filter :challenge
  filter :user_id
  filter :address
  filter :created_at
  filter :updated_at

  form do |f|
    f.inputs do
      f.input :inquiry_name
      f.input :type_of_business
      f.input :inquiry_date
      f.input :credit_bureau
      f.input :challenge
      f.input :user
      f.input :address
    end
    f.actions
  end
end
