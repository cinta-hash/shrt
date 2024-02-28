Rails.application.routes.draw do
  resources :links
  devise_for :users
  
  authenticated :user do
    root 'links#index', as: :authenticated_root
  end

  root to: redirect('/users/sign_in')
end