Rails.application.routes.draw do
  devise_for :accounts, controllers: {
    registrations: 'accounts/registrations',
    sessions: 'accounts/sessions'
  }

  root to: 'accounts#index'

  resources :accounts, only: [:edit, :update, :destroy]
  get '/accounts/current', to: 'accounts#current'
end
