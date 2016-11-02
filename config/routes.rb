Rails.application.routes.draw do
  get 'geocode', to: 'geocode#search', as: 'search'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
