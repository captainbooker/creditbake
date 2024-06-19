ActiveAdmin.register User do
  permit_params :email, :password, :password_confirmation, :phone_number, :first_name, :last_name, :street_address, :city, :state, :postal_code, :country, :credits, :slug, :signature, :agreement

  index do
    selectable_column
    id_column
    column :email
    column :phone_number
    column :first_name
    column :last_name
    column :street_address
    column :city
    column :state
    column :postal_code
    column :country
    column :credits
    column :slug
    column :created_at
    actions
  end

  filter :email
  filter :phone_number
  filter :first_name
  filter :last_name
  filter :city
  filter :state
  filter :postal_code
  filter :country
  filter :credits
  filter :slug
  filter :created_at

  form do |f|
    f.inputs do
      f.input :email
      f.input :password, input_html: { autocomplete: "new-password" }, hint: "Leave blank if you don't want to change it"
      f.input :password_confirmation, hint: "Leave blank if you don't want to change it"
      f.input :phone_number
      f.input :first_name
      f.input :last_name
      f.input :street_address
      f.input :city
      f.input :state
      f.input :postal_code
      f.input :country
      f.input :credits
      f.input :slug
      f.input :signature
      f.input :agreement
    end
    f.actions
  end

  controller do
    def update
      if params[:user][:password].blank? && params[:user][:password_confirmation].blank?
        params[:user].delete(:password)
        params[:user].delete(:password_confirmation)
      end
      super
    end
  end
end
