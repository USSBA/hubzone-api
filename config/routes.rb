Rails.application.routes.draw do
  get 'search', to: 'geocode#search', as: 'search'

  get 'aws-hc', to: 'health_check#status', as: 'aws_hc'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
