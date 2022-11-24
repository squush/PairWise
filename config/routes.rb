Rails.application.routes.draw do
  require "sidekiq/web"
  devise_for :users

  authenticate :user, ->(user) { user.admin? } do
    mount Sidekiq::Web => '/sidekiq'
  end

  root to: "pages#home"

  resources :tournaments, only: %i[index new create show]

  resources :matchups, only: %i[edit]
end
