Rails.application.routes.draw do
  get 'search', to: 'search#index'

  root 'home#index'
end
