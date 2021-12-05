Rails.application.routes.draw do
  devise_for :users, :path_prefix => 'd'

  root to: 'home#index'
  match '/appointments/export', to: 'appointments#export', via: 'get', as: :export
  match '/appointments/download_file', to: 'appointments#download_file', via: 'get', as: :download_file
  
  resources :users
  resource :homes
  resources :appointments
  resources :professionals
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  
end
