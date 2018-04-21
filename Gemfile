source 'https://rubygems.org'

ruby '2.5.1'

gem 'rails', '~> 5.2.0'

gem 'hamlit'
gem 'mongoid'
gem 'mongo', '~> 2.4.2' # XXX 2.5 doesn't connect MongoDB
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
