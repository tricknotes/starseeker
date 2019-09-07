source 'https://rubygems.org'

ruby '2.6.4'

gem 'rails', '~> 6.0.0.rc1'

gem 'hamlit'
gem 'mongo', '~> 2.8.0' # For 'mongod version: 3.6.12 (MMAPv1)'
gem 'mongoid'
gem 'octokit'
gem 'omniauth'
gem 'omniauth-github'
gem 'omniauth-rails_csrf_protection'
gem 'pg', groups: %i(production), require: false
gem 'puma', require: false
gem 'redis'
gem 'roadie-rails'
gem 'sassc-rails'
gem 'settingslogic'
gem 'uglifier'

group :development do
  gem 'letter_opener'
  gem 'listen'
  gem 'pry', groups: %i(test)
  gem 'pry-rails', groups: %i(test)
  gem 'tapp', groups: %i(test)
  gem 'web-console'
  gem 'sqlite3', groups: %i(test)
end

group :test do
  gem 'capybara'
  gem 'factory_bot_rails'
  gem 'rspec-its'
  gem 'rspec-rails', groups: %i(development)
end
