Rails.application.routes.draw do
  resources :links
  
  devise_for :users
  
  authenticated :user do
    root 'links#index', as: :authenticated_root
  end

  # Route to redirect short URLs to original URLs
  get '/:short_url', to: 'links#redirect', as: 'redirect'

  root to: redirect('/users/sign_in')
end
