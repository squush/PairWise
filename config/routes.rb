Rails.application.routes.draw do
  require "sidekiq/web"
  devise_for :users

  authenticate :user, ->(user) { user.admin? } do
    mount Sidekiq::Web => '/sidekiq'
  end

  root to: "pages#home"

  resources :tournaments, only: %i[index new create show edit update] do
    resources :players, only: %i[create]
    resources :matchups, only: %i[index]
  end

  resources :matchups, only: %i[update create]

  get "/contact", to: "pages#contact_us", as: :contact_us
  get "/profile", to: "pages#my_profile", as: :my_profile
  get "/tournaments/:id/scoreboard", to: "tournaments#scoreboard", as: :event_scoreboard
  get "/my_tournaments", to: "tournaments#my_tournaments"
end
