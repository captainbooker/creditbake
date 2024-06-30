ActiveAdmin.register User do
  permit_params :email, :password, :password_confirmation, :phone_number, :first_name, :last_name, :street_address, :city, :state, :postal_code, :country, :credits, :free_attack, :slug, :signature, :agreement, :avatar,
                accounts_attributes: [:id, :account_number, :account_type, :account_type_detail, :account_status, :creditor_name, :name, :reason, :_destroy],
                clients_attributes: [:id, :name, :_destroy],
                credit_reports_attributes: [:id, :username, :password, :security_question, :service, :experian_score, :transunion_score, :equifax_score, :experian_score_change, :transunion_score_change, :equifax_score_change, :_destroy],
                public_records_attributes: [:id, :public_record_type, :reference_number, :reason, :_destroy],
                inquiries_attributes: [:id, :inquiry_name, :type_of_business, :inquiry_date, :credit_bureau, :address, :_destroy],
                letters_attributes: [:id, :name, :bureau, :mailed, :tracking_number, :experian_tracking_number, :transunion_tracking_number, :equifax_tracking_number, :_destroy],
                mailings_attributes: [:id, :letter_id, :pages, :color, :cost, :_destroy],
                spendings_attributes: [:id, :amount, :description, :token, :transactional_id, :_destroy]

  index do
    selectable_column
    id_column
    column :email
    column :phone_number
    column :first_name
    column :last_name
    column :credits
    column :free_attack
    column :slug
    column :created_at
    actions do |user|
      item "View", admin_user_path(user), class: "member_link"
    end
  end

  filter :email
  filter :phone_number
  filter :first_name
  filter :last_name
  filter :credits
  filter :free_attack
  filter :slug
  filter :created_at
  
  show do
    attributes_table do
      row :email
      row :phone_number
      row :first_name
      row :last_name
      row :street_address
      row :city
      row :state
      row :postal_code
      row :country
      row :credits
      row :free_attack
      row :slug
      row :agreement
      row :avatar do |user|
        image_tag url_for(user.avatar) if user.avatar.attached?
      end
      row :created_at
      row :updated_at
    end

    panel "Accounts" do
      table_for user.accounts do
        column :account_number
        column :account_type
        column :account_type_detail
        column :account_status
        column :creditor_name
        column :name
        column :reason
      end
    end

    panel "Credit Reports" do
      table_for user.credit_reports do
        column :username
        column :password
        column :security_question
        column :service
        column :experian_score
        column :transunion_score
        column :equifax_score
        column :experian_score_change
        column :transunion_score_change
        column :equifax_score_change
      end
    end

    panel "Public Records" do
      table_for user.public_records do
        column :public_record_type
        column :reference_number
        column :reason
      end
    end

    panel "Inquiries" do
      table_for user.inquiries do
        column :inquiry_name
        column :type_of_business
        column :inquiry_date
        column :credit_bureau
        column :address
      end
    end

    panel "Letters" do
      table_for user.letters do
        column :name
        column :bureau
        column :mailed
        column :tracking_number
        column :experian_tracking_number
        column :transunion_tracking_number
        column :equifax_tracking_number
      end
    end

    panel "Mailings" do
      table_for user.mailings do
        column :letter_id
        column :pages
        column :color
        column :cost
      end
    end

    panel "Spendings" do
      table_for user.spendings do
        column :amount
        column :description
        column :token
        column :transactional_id
      end
    end
  end

  form do |f|
    f.inputs 'User Details' do
      f.input :email
      f.input :phone_number
      f.input :first_name
      f.input :last_name
      f.input :street_address
      f.input :city
      f.input :state
      f.input :postal_code
      f.input :credits
      f.input :free_attack
      f.input :agreement
      f.input :avatar, as: :file
    end

    f.has_many :accounts, allow_destroy: true, new_record: true do |a|
      a.input :account_number
      a.input :account_type
      a.input :account_type_detail
      a.input :account_status
      a.input :creditor_name
      a.input :name
      a.input :reason
    end

    f.has_many :credit_reports, allow_destroy: true, new_record: true do |cr|
      cr.input :username
      cr.input :password
      cr.input :security_question
      cr.input :service
      cr.input :experian_score
      cr.input :transunion_score
      cr.input :equifax_score
      cr.input :experian_score_change
      cr.input :transunion_score_change
      cr.input :equifax_score_change
    end

    f.has_many :public_records, allow_destroy: true, new_record: true do |pr|
      pr.input :public_record_type
      pr.input :reference_number
      pr.input :reason
    end

    f.has_many :inquiries, allow_destroy: true, new_record: true do |i|
      i.input :inquiry_name
      i.input :type_of_business
      i.input :inquiry_date
      i.input :credit_bureau
      i.input :address
    end

    f.has_many :letters, allow_destroy: true, new_record: true do |l|
      l.input :name
      l.input :bureau
      l.input :mailed
      l.input :tracking_number
      l.input :experian_tracking_number
      l.input :transunion_tracking_number
      l.input :equifax_tracking_number
    end

    f.has_many :mailings, allow_destroy: true, new_record: true do |m|
      m.input :letter_id
      m.input :pages
      m.input :color
      m.input :cost
    end

    f.has_many :spendings, allow_destroy: true, new_record: true do |s|
      s.input :amount
      s.input :description
      s.input :token
      s.input :transactional_id
    end

    f.actions
  end

  controller do
    def update
      if params[:user][:password].blank? && params[:user][:password_confirmation].blank?
        params[:user].delete(:password)
        params[:user].delete(:password_confirmation)
      end

      Rails.logger.debug("User params: #{params[:user]}") # Debugging line
      super
    end
  end
end
