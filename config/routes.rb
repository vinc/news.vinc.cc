Rails.application.routes.draw do
  resource :user, only: %i(show create update destroy) do
    resources :permalinks, only: %i(index show create destroy)

    member do
      put 'read'
      put 'unread'
    end
  end

  resource :settings

  mount ActionCable.server => '/cable'

  get 'search', to: 'search#index'

  root 'home#index'
end
