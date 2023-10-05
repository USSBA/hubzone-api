source 'https://rubygems.org'

gem 'dotenv-rails' # Use dotenv to load environment variables
gem 'excon-rails'
gem 'faraday', '~> 0.9.2' # simple http requests
gem 'ffi', '~> 1.9.24' # CVS-2018-1000201
gem 'jbuilder', '~> 2.5' # Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'newrelic_rpm', '~> 4.5' # NewRelic Application Performance Monitoring
gem 'pg', '~> 0.18' # Use postgresql as the database for Active Record
gem 'puma', '~> 4.3' # Use Puma as the app server
gem 'rails', '~> 7.1', '>= 7.1.0' # Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'strong_migrations', '~> 0.3' # Catch unsafe migrations at dev time
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 3.0'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin AJAX possible
# gem 'rack-cors'

group :development, :test do
  gem 'byebug', platform: :mri # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'rb-readline'
  gem 'rspec-rails', '~> 4.0', '>= 4.0.0'
  gem 'rubocop', '~> 1.19.0' # Enforce ruby code style
  gem 'rubocop-rails', '~> 2.12'
  gem 'rubocop-rspec', '~> 2.5'
  gem 'simplecov', require: false # determine code coverage of tests
end

group :development do
  gem 'listen', '~> 3.0.5'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

group :test do
  gem 'webmock' # used by vcr gem
end
