Rails.application.routes.draw do
  mount ActionCable.server => '/cable'

  get 'search', to: 'search#index'

  root 'home#index'
end
