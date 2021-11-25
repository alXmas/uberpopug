Rails.application.routes.draw do
  root 'tasks#index'
  resources :tasks, only: %i[new create] do
    post :reassign, on: :collection
    post :complete, on: :member
  end
  post 'auth/:provider', to: 'auth#request', as: :auth_request
  get 'auth/:provider/callback', to: 'auth#callback', as: :callback_auth
end
