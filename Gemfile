source 'https://rubygems.org'

ruby '3.3.5'

gem 'rails', '~> 7.2.0'

gem 'haml'
gem 'mongoid', github: 'mongodb/mongoid'
gem 'octokit'
gem 'omniauth'
gem 'omniauth-github'
gem 'omniauth-rails_csrf_protection'
gem 'pg'
gem 'propshaft'
gem 'puma', require: false
gem 'redis-client'
gem 'roadie-rails'

group :development do
  gem 'brakeman'
  gem 'debug', groups: %i(test)
  gem 'letter_opener_web'
  gem 'web-console'
end

group :test do
  gem 'capybara'
  gem 'factory_bot_rails'
  gem 'rspec-its'
  gem 'rspec-rails', groups: %i(development)
end
