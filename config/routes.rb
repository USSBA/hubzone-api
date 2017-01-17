Rails.application.routes.draw do
  scope '/api' do
    get 'search', to: 'geocode#search', as: 'search'

    # A route for AWS to hit to "test" the health of the instance
    get 'aws-hc', to: 'health_check#status', as: 'aws_hc'
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
