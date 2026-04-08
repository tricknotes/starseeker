source 'https://rubygems.org'

ruby '4.0.2'

gem 'rails', '~> 8.1.0'

gem 'haml'
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
