Rails.application.routes.draw do
  devise_for :users
  root to: "pages#home"

  resources :tournaments, only: %i[index new create show]

  resources :matchups, only: %i[edit update]

  get "/contact", to: "pages#contact_us", as: :contact_us
  get "/profile", to: "pages#my_profile", as: :my_profile
<<<<<<< HEAD
  get "/tournaments/:id/scoreboard", to: "tournaments#scoreboard", as: :event_scoreboard
=======

  get "/my_tournaments", to: "tournaments#my_tournaments"
>>>>>>> 03f184c5bed1f293a6849600ba164d090e88289f
end
