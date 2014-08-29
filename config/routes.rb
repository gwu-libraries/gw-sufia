GwSufia::Application.routes.draw do
  mount BrowseEverything::Engine => '/browse'
  root 'homepage#index'

  blacklight_for :catalog

if Rails.env.production?
  devise_for :users, {
    :controllers => {
      :omniauth_callbacks => 'users/omniauth_callbacks',
    }, :skip => [ :sessions ]
  }

  devise_scope :users do
      get 'logout' => 'sessions#destroy', as: :destroy_user_session
      get 'login' => 'sessions#new', as: :new_user_session
  end
else
  devise_for :users, {
    :controllers => {
      :omniauth_callbacks => 'users/omniauth_callbacks',
    }
  }
end

  Hydra::BatchEdit.add_routes(self)

  # This must be the very last route in the file because it has a catch all route for 404 errors.
  # This behavior seems to show up only in production mode.
  mount Sufia::Engine => '/'
end
