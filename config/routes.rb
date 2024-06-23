require 'sidekiq/web'
# config/routes.rb
Rails.application.routes.draw do
  get 'contacts/new'
  get 'contacts/create'
  get 'stripe_payments/create'
  authenticate :user do
    mount Blazer::Engine, at: "blazer"
    mount ActiveAnalytics::Engine, at: "analytics" # http://localhost:3000/analytics
    mount Sidekiq::Web => "/sidekiq"
  end
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  # Devise routes for user authentication
  devise_for :users, controllers: { registrations: 'users/registrations' }

  devise_scope :user do
    authenticated :user do
      root 'dashboards#index', as: :authenticated_root
      get 'complete_registration', to: 'users/registrations#edit_profile', as: :edit_profile
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

  get '/payment', to: 'payments#index', as: 'payment'
  post '/payment', to: 'payments#create'
  get 'credit_reports', to: 'dashboards#index'
  get 'credit_reports/scores', to: 'dashboards#scores'
  post 'webhooks/maverick', to: 'webhooks#authorize_net'
  get 'privacy_policy', to: 'pages#privacy_policy', as: 'privacy_policy'
  get 'terms_of_use', to: 'pages#terms_of_use', as: 'terms_of_use'
  get 'refund_policy', to: 'pages#refund_policy', as: 'refund_policy'
  get '/sitemap.xml', to: 'pages#sitemap', defaults: { format: 'xml' }

  resources :contacts, only: [:new, :create]

  resources :letters do
    post 'mail', to: 'mailings#create', as: :mail
    get 'calculate_cost', to: 'mailings#calculate_cost'
  end
  resources :spendings, only: [:index]
end
