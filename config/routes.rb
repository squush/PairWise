Rails.application.routes.draw do
  # require "sidekiq/web"
  devise_for :users

  # authenticate :user, ->(user) { user.admin? } do
  #   mount Sidekiq::Web => '/sidekiq'
  # end

  root to: "pages#home"

  resources :tournaments, only: %i[index new create show edit update destroy] do
    resources :players, only: %i[create]
    resources :matchups, only: %i[index]
  end

  resources :matchups, only: %i[update create]

  get "/players/:id", to: "players#deactivate", as: :deactivate_player
  get "/players/:id/reactivate", to: "players#reactivate", as: :reactivate_player

  get "/contact", to: "pages#contact_us", as: :contact_us
  get "/profile", to: "pages#my_profile", as: :my_profile
  get "/tournaments/:id/scoreboard", to: "tournaments#scoreboard", as: :scoreboard
  get "/my_tournaments", to: "tournaments#my_tournaments"
  get "/tournaments/:id/report", to: "tournaments#tournament_report", as: :final_report
  get "/tournaments/:id/generate_matchups", to: "matchups#matchups_for_round", as: :generate_matchups

end
