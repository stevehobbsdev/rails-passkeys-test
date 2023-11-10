Rails.application.routes.draw do
  get 'signin/index'
  get 'signup' => 'signup#index'
  post 'signup' => 'signup#register'
  get 'signin' => 'signin#index'
  post 'signin' => 'signin#index_post'
  
  get 'signin/password' => 'signin#password'
  post 'signin/password' => 'signin#verify_password'
  
  get 'account' => 'account#index'

  get 'signup/verify'
  get 'signup/callback'
  get 'home/index'
  get 'account/register'
  post 'account/register_callback'
  get 'account/verify'
  post 'account/verify_callback'
  get 'account/login'
  post 'account/login' => 'account#do_login'
  get 'account/logout'

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  root "home#index"
end
