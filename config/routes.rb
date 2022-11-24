Rails.application.routes.draw do
  devise_for :users
  root to: "pages#home"

  resources :tournaments, only: %i[index new create show]

  resources :matchups, only: %i[edit update]

  get "/contact", to: "pages#contact_us", as: :contact_us
  get "/profile", to: "pages#my_profile", as: :my_profile
  get "/tournaments/:id/scoreboard", to: "tournaments#scoreboard", as: :event_scoreboard
end
