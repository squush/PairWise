Rails.application.routes.draw do
  devise_for :users
  root to: "pages#home"

  resources :tournaments, only: %i[index show]
end
