source 'https://rubygems.org'

ruby '2.2.3'

gem 'rails', '~> 4.2.0'

gem 'haml-rails'
gem 'jquery-rails'
gem 'mongoid', github: 'mongodb/mongoid' # To use https://github.com/mongodb/mongoid/pull/4179
gem 'octokit'
gem 'omniauth'
gem 'omniauth-github'
gem 'pg', groups: %w(production), require: false
gem 'puma', require: false
gem 'redis'
gem 'roadie-rails'
gem 'sass-rails'
gem 'settingslogic'
gem 'sqlite3', groups: %w(test development), require: false
gem 'uglifier'

group :development do
  gem 'letter_opener'
  gem 'pry-rails', groups: %w(test)
  gem 'pry', groups: %w(test)
  gem 'quiet_assets'
  gem 'tapp', groups: %w(test)
  gem 'web-console'
end

group :test do
  gem 'capybara'
  gem 'factory_girl_rails'
  gem 'rspec-its'
  gem 'rspec-rails', groups: %w(development)
end

group :production do
  gem 'rails_12factor' # for Heroku
end
