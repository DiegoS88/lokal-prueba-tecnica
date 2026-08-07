Rails.application.routes.draw do
root "catalog#index"

  # Carrito guardado en session
  get "cart" => "cart#show"
  post "cart/add" => "cart#add"
  post "cart/update" => "cart#update"
  delete "cart/remove" => "cart#remove"

  resources :orders, only: %i[create show]

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  get "up" => "rails/health#show", as: :rails_health_check

  # Los navegadores piden /favicon.ico aunque el layout use /icon.svg.
  get "favicon.ico", to: redirect("/icon.svg")
end
