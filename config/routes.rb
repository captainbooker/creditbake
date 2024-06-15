# config/routes.rb
Rails.application.routes.draw do
  get 'contacts/new'
  get 'contacts/create'
  get 'stripe_payments/create'
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  # Devise routes for user authentication
  devise_for :users, controllers: { registrations: 'users/registrations' }

  devise_scope :user do
    authenticated :user do
      root 'dashboards#index', as: :authenticated_root
      get 'profile/edit', to: 'users/registrations#edit_profile', as: :edit_profile
      patch 'profile/update', to: 'users/registrations#update_profile', as: :users_update_profile
    end

    unauthenticated do
      root 'pages#landing', as: :unauthenticated_root
    end
  end

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

  get 'challenge', to: 'dashboards#disputing', as: 'challenge'
  get 'letters', to: 'dashboards#letters', as: 'letters'
  get 'credit_report', to: 'credit_reports#credit_report', as: 'credit_report'
  get 'create_attack', to: 'dashboards#create_attack', as: 'create_attack'
  patch 'disputing/save_challenges', to: 'dashboards#save_challenges', as: 'save_challenges'
  post 'import_credit_report', to: 'credit_reports#import', as: 'import_credit_report'
  post 'credit_reports/download_all_files', to: 'credit_reports#download_all_files', as: 'download_all_files'
  
  get 'success', to: 'dashboards#success', as: 'success'
  get 'cancel', to: 'dashboards#cancel'

  get '/payment', to: 'payments#new', as: 'payment'
  post '/payment', to: 'payments#create'
  get 'credit_reports', to: 'dashboards#index'
  get 'credit_reports/scores', to: 'dashboards#scores'

  resources :contacts, only: [:new, :create]

  resources :letters do
    post 'mail', to: 'mailings#create', as: :mail
    get 'calculate_cost', to: 'mailings#calculate_cost'
  end
  resources :spendings, only: [:index]
end
