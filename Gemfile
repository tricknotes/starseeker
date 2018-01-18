source 'https://rubygems.org'

ruby '2.5.0'

gem 'rails', '~> 5.1.2'

gem 'hamlit'
gem 'jquery-rails'
gem 'mongoid'
gem 'mongo', '~> 2.4.2' # XXX 2.5.0 doesn't connect MongoDB
gem 'octokit'
gem 'omniauth'
gem 'omniauth-github'
gem 'pg', '< 1.0', groups: %i(production), require: false # pg 1.0 doesn't work on Rails 5.1. https://bitbucket.org/ged/ruby-pg/issues/270/pg-100-x64-mingw32-rails-server-not-start
gem 'puma', require: false
gem 'redis'
gem 'roadie-rails'
gem 'sass-rails'
gem 'settingslogic'
gem 'sqlite3', groups: %i(test development), require: false
gem 'uglifier'

group :development do
  gem 'letter_opener'
  gem 'listen'
  gem 'pry', groups: %i(test)
  gem 'pry-rails', groups: %i(test)
  gem 'tapp', groups: %i(test)
  gem 'web-console'
end

group :test do
  gem 'capybara'
  gem 'factory_girl_rails'
  gem 'rspec-its'
  gem 'rspec-rails', groups: %i(development)
end
