ActiveAdmin.register CreditReport do
  # Permit parameters for assignment
  permit_params :client_id, :user_id, :username, :password, :security_question, :service, :experian_score, :transunion_score, :equifax_score, :experian_score_change, :transunion_score_change, :equifax_score_change

  index do
    selectable_column
    id_column
    column :client_id
    column :user_id
    column :username
    column :service
    column :experian_score
    column :transunion_score
    column :equifax_score
    column :experian_score_change
    column :transunion_score_change
    column :equifax_score_change
    column :created_at
    column :updated_at
    actions
  end

  filter :client_id
  filter :user_id
  filter :username
  filter :service
  filter :experian_score
  filter :transunion_score
  filter :equifax_score
  filter :experian_score_change
  filter :transunion_score_change
  filter :equifax_score_change
  filter :created_at
  filter :updated_at

  form do |f|
    f.inputs do
      f.input :client
      f.input :user
      f.input :username
      f.input :password
      f.input :security_question
      f.input :service
      f.input :experian_score
      f.input :transunion_score
      f.input :equifax_score
      f.input :experian_score_change
      f.input :transunion_score_change
      f.input :equifax_score_change
    end
    f.actions
  end
end
