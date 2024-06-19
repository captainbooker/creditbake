ActiveAdmin.register Letter do
  # Permit parameters for assignment
  permit_params :name, :bureau, :experian_document, :transunion_document, :equifax_document, :user_id, :mailed, :tracking_number, :experian_tracking_number, :transunion_tracking_number, :equifax_tracking_number

  index do
    selectable_column
    id_column
    column :name
    column :bureau
    column :user_id
    column :mailed
    column :tracking_number
    column :experian_tracking_number
    column :transunion_tracking_number
    column :equifax_tracking_number
    column :created_at
    column :updated_at
    actions
  end

  filter :name
  filter :bureau
  filter :user_id
  filter :mailed
  filter :tracking_number
  filter :experian_tracking_number
  filter :transunion_tracking_number
  filter :equifax_tracking_number
  filter :created_at
  filter :updated_at

  form do |f|
    f.inputs do
      f.input :name
      f.input :bureau
      f.input :experian_document
      f.input :transunion_document
      f.input :equifax_document
      f.input :user
      f.input :mailed
      f.input :tracking_number
      f.input :experian_tracking_number
      f.input :transunion_tracking_number
      f.input :equifax_tracking_number
    end
    f.actions
  end
end
