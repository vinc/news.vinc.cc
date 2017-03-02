Rails.application.routes.draw do
  resource :settings

  mount ActionCable.server => '/cable'

  get 'search', to: 'search#index'

  root 'home#index'
end
