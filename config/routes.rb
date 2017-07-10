require 'api_constraints'

Rails.application.routes.draw do
  namespace 'api', defaults: {format: 'json'} do
    scope module: :v2, constraints: ApiConstraints.new(version: 2) do
      get 'search', to: 'geocode#search', as: 'v2_search'
    end
    scope module: :v1, constraints: ApiConstraints.new(version: 1, default: true) do
      get 'search', to: 'geocode#search', as: 'search'
    end
  end

  # Leave non-versioned routes as a scope.
  scope 'api' do
    # A route for AWS to hit to "test" the health of the instance
    get 'aws-hc', to: 'health_check#status', as: 'aws_hc'

    # A route for AWS to hit to "test" the health of the instance
    get 'version', to: 'version#show', as: 'version'
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
