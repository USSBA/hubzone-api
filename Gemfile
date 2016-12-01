source 'https://rubygems.org'

gem 'faraday', '~> 0.9.2' # simple http requests
gem 'jbuilder', '~> 2.5' # Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'pg', '~> 0.18' # Use postgresql as the database for Active Record
gem 'puma', '~> 3.0' # Use Puma as the app server
gem 'rails', '~> 5.0.0', '>= 5.0.0.1' # Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
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
  gem 'rspec-rails', '~> 3.5'
  gem 'rubocop', require: false
  gem 'simplecov', require: false # determine code coverage of tests
end

group :development do
  gem 'listen', '~> 3.0.5'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

group :test do
  gem 'vcr' # capture external API traffic for testing
  gem 'webmock' # used by vcr gem
end
