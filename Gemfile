source 'https://rubygems.org'

ruby '3.0.0'

gem 'rails', '~> 6.1.0.rc2'

gem 'hamlit'
gem 'mongoid', github: 'mongodb/mongoid', branch: 'master' # To use Rails 6.1
gem 'octokit'
gem 'omniauth'
gem 'omniauth-github'
gem 'omniauth-rails_csrf_protection'
gem 'pg'
gem 'puma', require: false
gem 'redis'
gem 'roadie-rails'
gem 'sassc-rails'
gem 'settingslogic'
gem 'uglifier'

group :development do
  gem 'letter_opener_web'
  gem 'listen'
  gem 'pry', groups: %i(test)
  gem 'pry-rails', groups: %i(test)
  gem 'tapp', groups: %i(test)
  gem 'web-console'
end

group :test do
  gem 'capybara'
  gem 'factory_bot_rails'
  gem 'rspec-its'
  gem 'rspec-rails', groups: %i(development)
end
