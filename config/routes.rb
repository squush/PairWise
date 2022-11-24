Rails.application.routes.draw do
  devise_for :users
  root to: "pages#home"

  resources :tournaments, only: %i[index new create show]

  resources :matchups, only: %i[edit update]
end
