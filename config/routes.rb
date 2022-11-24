Rails.application.routes.draw do
  devise_for :users
  root to: "pages#home"

  resources :tournaments, only: %i[index new create show] do
    resources :players, only: %i[create]
  end

  resources :matchups, only: %i[update]
  get "/matchups/:id/set_score", to: "matchups#set_score", as: :set_score

  get "/contact", to: "pages#contact_us", as: :contact_us
  get "/profile", to: "pages#my_profile", as: :my_profile

  get "/my_tournaments", to: "tournaments#my_tournaments"
end
