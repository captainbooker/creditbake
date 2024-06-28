ActiveAdmin.register User do
  permit_params :email, :password, :password_confirmation, :phone_number, :first_name, :last_name, :street_address, :city, :state, :postal_code, :country, :credits, :free_attack, :slug, :signature, :agreement,
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
      super
    end
  end
end
