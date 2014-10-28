Rails.application.routes.draw do
  resource :session, controller: 'sessions', only: [:create]
  get '/sign_in' => 'sessions#new', as: 'sign_in'
  delete '/sign_out' => 'sessions#destroy', as: 'sign_out'

  resources :dists, only: :index

  root to: 'sessions#new'
end
