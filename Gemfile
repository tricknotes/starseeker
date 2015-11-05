source 'https://rubygems.org'

ruby '2.2.3'

gem 'rails', '~> 4.2.0'

gem 'haml-rails'
gem 'jquery-rails'
gem 'mongoid'
gem 'octokit'
gem 'omniauth'
gem 'omniauth-github'
gem 'pg', groups: %i(production), require: false
gem 'puma', require: false
gem 'redis'
gem 'roadie-rails'
gem 'sass-rails'
gem 'settingslogic'
gem 'sqlite3', groups: %i(test development), require: false
gem 'uglifier'

group :development do
  gem 'letter_opener'
  gem 'pry-rails', groups: %i(test)
  gem 'pry', groups: %i(test)
  gem 'quiet_assets'
  gem 'tapp', groups: %i(test)
  gem 'web-console'
end

group :test do
  gem 'capybara'
  gem 'factory_girl_rails'
  gem 'rspec-its'
  gem 'rspec-rails', groups: %i(development)
end

group :production do
  gem 'rails_12factor' # for Heroku
end
