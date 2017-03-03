Rails.application.routes.draw do
  resource :user, only: %i(show create update destroy)
  resource :settings

  mount ActionCable.server => '/cable'

  get 'search', to: 'search#index'

  root 'home#index'
end
