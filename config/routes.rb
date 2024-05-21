Rails.application.routes.draw do
  # Root route


  # Devise routes for user authentication
  devise_for :users

  # Nested routes for clients and their profiles under users
  resources :clients do
    resource :profile, only: [:show, :edit, :update]  # Assuming each client has one profile
    resources :credit_reports, only: [:new, :create, :show]
  end

  # Routes for disputes
  resources :disputes, only: [:index, :show]

  # Catch-all route for errors or undefined paths
  match '*path', to: 'errors#not_found', via: :all

  authenticated :user do
    root 'pages#dashboard', as: :authenticated_root
  end

  unauthenticated do
    root 'pages#landing', as: :unauthenticated_root
  end
end
