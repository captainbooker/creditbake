Rails.application.routes.draw do
  # Root route
  root 'users#settings'

  # Devise routes for user authentication
  devise_for :users

  # Nested routes for clients and their profiles under users
  resources :users, only: [] do
    resources :credit_reports, only: [:new, :create, :show]
  end

  # Routes for disputes
  resources :disputes, only: [:index, :show]
  resource :user, only: [:update]
  get 'settings', to: 'users#settings', as: 'user_settings'
  delete 'users/:id/delete_id_document', to: 'users#delete_id_document', as: 'delete_id_document_user'
  delete 'users/:id/delete_utility_bill', to: 'users#delete_utility_bill', as: 'delete_utility_bill_user'

  get 'disputing', to: 'dashboards#disputing', as: 'disputing'
  get 'letters', to: 'dashboards#letters', as: 'letters'
  post 'create_attack', to: 'dashboards#create_attack', as: 'create_attack'
  patch 'disputing/save_challenges', to: 'dashboards#save_challenges', as: 'save_challenges'
  post 'import_credit_report', to: 'credit_reports#import', as: 'import_credit_report'

  authenticated :user do
    root 'pages#dashboard', as: :authenticated_root
  end

  unauthenticated do
    root 'pages#landing', as: :unauthenticated_root
  end
end
